-- =============================================
-- Author:		TSI
-- =============================================
CREATE PROCEDURE [dbo].[sp_CC_GetCautionNotes]
@RoutingNum VARCHAR(50),
@AccountNum VARCHAR(50),
@IdIssuer INT = 0,
@CheckNum VARCHAR(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Meses INT = -6
	DECLARE @N int

	DECLARE @Rejected INT = 0
	DECLARE @NoFunds INT = 0
	DECLARE @Closed BIT = 0


	IF (@IdIssuer <= 0) OR (@IdIssuer IS NULL)
	BEGIN
		SELECT TOP 1 @IdIssuer = IdIssuer
		FROM dbo.IssuerChecks
		WHERE RoutingNumber=@RoutingNum AND AccountNumber=@AccountNum
    END
    
	SET @IdIssuer = ISNULL(@IdIssuer,0)

	------------------
	-- temporal solo para demo
	DECLARE @DemoIssuer INT
	SELECT @DemoIssuer=Value FROM dbo.GlobalAttributes WHERE Name='Tsi/DemoIssuer'
	IF @DemoIssuer > 0 SET @IdIssuer=@DemoIssuer
	

	CREATE TABLE #CautionNotes(
		[Src] VARCHAR(50),
		[Status] VARCHAR(50),
		[Text] VARCHAR(100),		
		Num INT,
		[TextTag] VARCHAR(100)
	)

	IF OBJECT_ID('tempdb.dbo.#RR', 'U') IS NOT NULL DROP TABLE #RR; 


	-- Issuer inactivo
	---------------------------------
	/*SET @N = 1
	SELECT @N = StActive FROM dbo.IssuerChecks WHERE IdIssuer = @IdIssuer
	IF ISNULL(@N,1) = 0
	INSERT INTO #CautionNotes VALUES( 'MAXI', 'ERROR', 'ClosedAccount', @N )
	*/

	-- Rechazados
	---------------------------------
	--Todo: se va a crear nueva tabla para ver los rechazos por cheque


	--Buscar si el Issuer tiene cheques rechazados en un periodo
	SELECT @N = COUNT(CHR.IdCheck)
	FROM CheckRejectHistory CHR
	JOIN Checks CH ON (CH.IdCheck=CHR.IdCheck)
	WHERE CH.IdIssuer = @IdIssuer
	AND CAST(CHR.DateOfReject AS DATE) >= CAST(DATEADD(mm, @Meses, GETDATE()) AS DATE)

	IF @N > 0
	INSERT INTO #CautionNotes VALUES( 'MAXI', 'WARN', 'HasChecksRejected', @N, '')

	/*
	SELECT CD.IdCheck, MAX(CD.IdCheckDetail)[IdCheckDetail]
	INTO #RR
	FROM dbo.Checks CH
	JOIN dbo.CheckDetails CD ON (CD.IdCheck=CH.IdCheck AND CD.IdStatus=CH.IdStatus)
	WHERE CH.IdIssuer = @IdIssuer
	AND CD.IdStatus = 31
	AND CAST(CD.DateOfMovement AS DATE) >= CAST(DATEADD(mm, @Meses, GETDATE()) AS DATE)
	GROUP BY CD.IdCheck

	-- Sin Fondos
	SELECT @N = COUNT(*)
	FROM #RR
	JOIN dbo.CheckDetails CD ON CD.IdCheckDetail = #RR.IdCheckDetail
	WHERE  CD.Note LIKE '%Insuf%'
	--
	IF @N > 0
	INSERT INTO #CautionNotes VALUES( 'MAXI', 'WARN', 'HasChecksNoFunds', @N )
	*/

	---------------------------------
	-- Cuenta en Deny List
	IF EXISTS(SELECT I.IdIssuer
			FROM DenyListIssuerChecks DL JOIN IssuerChecks I ON (DL.IdIssuerCheck=I.IdIssuer)
			WHERE RoutingNumber=@RoutingNum AND AccountNumber=@AccountNum AND IdGenericStatus=1)
		INSERT INTO #CautionNotes VALUES( 'MAXI', 'ERROR', 'CC_NOTE_AccInDenyList', 1, '' )



	----------------------------------
	-- Revisar si hay mas de un IRD para este Ruting-Account,  si es asi entonces regreso error, pk ya no se debe procesar
	IF RTRIM(@CheckNum) > ''
	BEGIN
		DECLARE @CantRejected INT = 0;
		DECLARE @RInt BIGINT = CAST( ISNULL(@RoutingNum,0) AS BIGINT);
		DECLARE @AInt BIGINT = CAST( ISNULL(@AccountNum,0) AS BIGINT);
		DECLARE @CInt INT    = CAST( ISNULL(@CheckNum,  0) AS INT);
	
		SELECT @CantRejected = COUNT(*)
		FROM dbo.CheckRejectHistory R
		JOIN dbo.Checks C ON C.IdCheck=R.IdCheck
		WHERE 1=1
		AND TRY_CAST(C.RoutingNumber AS BIGINT) = @RInt
		AND TRY_CAST(C.Account       AS BIGINT) = @AInt
		AND TRY_CAST(C.CheckNumber   AS INT)    = @CInt


		IF @CantRejected >= 2
		BEGIN
			INSERT INTO #CautionNotes VALUES( 'MAXI', 'ERROR', 'HasIrdRejected', @CantRejected, '' );
		END;
	END;
	

	---------------------------------
	IF (SELECT COUNT(*) FROM #CautionNotes) = 0
	INSERT INTO #CautionNotes VALUES( 'MAXI', 'INFO', 'NoComments', @N, '' )


	--HasChecksNoFunds
	--CC_NOTE_AccInDenyList
	--NoComments


	--Revisar ABA Blocked
	IF(SELECT COUNT(*) FROM dbo.ABABlocked AB WHERE AB.ABA=@RoutingNum)>0
		INSERT INTO #CautionNotes VALUES( 'MAXI', 'ERROR', 'ABABlocked', @N, '' )

	UPDATE #CautionNotes SET [TextTag] = [Text] WHERE ISNULL(TextTag,'')='';

	SELECT * FROM #CautionNotes;


END

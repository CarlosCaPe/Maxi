-- =============================================
-- Author:		TSI
-- =============================================
CREATE PROCEDURE [dbo].[sp_CC_GetAccountCheckSummary]
@RoutingNum VARCHAR(100),
@AccountNum VARCHAR(100),
@IdIssuer INT = 0,
@IdLang INT = 0
AS
/********************************************************************
<Author>TSI</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="15/06/2022" Author="jdarellano" Name="#1">Performance: se agregan with(nolock) y se mejora método de búsqueda.</log>
</ChangeLog>
*********************************************************************/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IssuerName VARCHAR(MAX);
	DECLARE @TotProcessed INT = 0;
	DECLARE @TotRejected INT = 0;
	DECLARE @RetDate DATETIME;
	DECLARE @RetReason VARCHAR(MAX) = '';

	DECLARE @Meses INT = -6;
	
	IF (@IdIssuer <= 0) OR (@IdIssuer IS NULL)
	BEGIN
		SELECT TOP 1 @IdIssuer = IdIssuer
		FROM dbo.IssuerChecks WITH (NOLOCK)
		WHERE RoutingNumber = @RoutingNum AND AccountNumber = @AccountNum;
    END
    
	SET @IdIssuer = ISNULL(@IdIssuer,0);

	------------------
	-- temporal solo para demo
	DECLARE @DemoIssuer INT;
	SELECT @DemoIssuer = [Value] FROM dbo.GlobalAttributes WITH (NOLOCK) WHERE [Name] = 'Tsi/DemoIssuer';
	IF @DemoIssuer > 0 SET @IdIssuer = @DemoIssuer;

	SELECT @IssuerName = [Name] FROM dbo.IssuerChecks WITH (NOLOCK) WHERE IdIssuer = @IdIssuer;
	
	--------------------------------------
	-- Busca cantidad de procesados
	/*;WITH t1 AS(--#1
		SELECT MAX(CD.IdCheckDetail)[IdCheckDetail]
		FROM dbo.Checks CH
		JOIN dbo.CheckDetails CD ON (CD.IdCheck=CH.IdCheck)
		WHERE CH.IdIssuer = @IdIssuer
		AND CAST(CD.DateOfMovement AS DATE) >= CAST(DATEADD(mm, @Meses, GETDATE()) AS DATE)
		GROUP BY CD.IdCheck
	)
	SELECT @TotProcessed = COUNT(*) FROM t1*/--#1

	SELECT MAX(CD.IdCheckDetail)[IdCheckDetail]
	INTO #t1--#1
	FROM dbo.Checks CH WITH (NOLOCK)
	JOIN dbo.CheckDetails CD WITH (NOLOCK) ON (CD.IdCheck=CH.IdCheck)
	WHERE CH.IdIssuer = @IdIssuer
	AND CAST(CD.DateOfMovement AS DATE) >= CAST(DATEADD(mm, @Meses, GETDATE()) AS DATE)
	GROUP BY CD.IdCheck;

	SELECT @TotProcessed = COUNT(1) FROM #t1;--#1
	------------------------------------------
	--Cuenta cheques procesados en general
	--SELECT @TotProcessed = COUNT(*)
	--FROM dbo.Checks CH
	--WHERE CH.IdIssuer = @Issuer
	--AND CAST(CH.DateOfMovement AS DATE) >= DATEADD(mm, @Meses, CAST(GETDATE() AS DATE))


	------------------------------------------


	--------------------------------------------------
	-- Busca cheques retornados por el banco
	-- Status 31 = Rejected
	--------------------------------------------------
	--IF OBJECT_ID('tempdb.dbo.#RR', 'U') IS NOT NULL DROP TABLE #RR;

	SELECT CHR.IdCheck, CHR.DateOfReject, CHR.IdReturnedReason, RR.RTR_Name, CONCAT('ReturnedReason_',CHR.IdReturnedReason) [RRLangKey]
	INTO #RR
	FROM dbo.CheckRejectHistory CHR WITH (NOLOCK)
	INNER JOIN dbo.Checks CH WITH (NOLOCK) ON (CH.IdCheck=CHR.IdCheck)
	LEFT JOIN dbo.CC_ReturnedReasons RR WITH (NOLOCK) ON (RR.ReturnedReason_ID = CHR.IdReturnedReason)
	WHERE CH.IdIssuer = @IdIssuer
	AND CAST(CHR.DateOfReject AS DATE) >= CAST(DATEADD(mm, @meses, GETDATE()) AS DATE);
	
	/*
	SELECT CD.IdCheck, MAX(CD.IdCheckDetail)[IdCheckDetail]
	INTO #RR
	FROM dbo.Checks CH
	JOIN dbo.CheckDetails CD ON (CD.IdCheck=CH.IdCheck AND CD.IdStatus=CH.IdStatus)
	WHERE CH.IdIssuer = @IdIssuer
	AND CD.IdStatus = 31
	--and CD.ReturnedBy = 'BANK' o CD.IdReturnedReason is not null   Se agregara columna para saber si es regresado por el banco
	AND CAST(CD.DateOfMovement AS DATE) >= CAST(DATEADD(mm, @Meses, GETDATE()) AS DATE)
	GROUP BY CD.IdCheck
	*/

	-- Cuenta
	--SELECT @TotRejected = COUNT(*) FROM #RR
	SELECT @TotRejected = COUNT(1) FROM #RR;--#1

	-- Datos del ultimo retorno
	/*
	SELECT TOP 1
	  @RetDate = CD.DateOfMovement,
	  @RetReason = CD.Note
	FROM #RR JOIN dbo.CheckDetails CD ON CD.IdCheckDetail=#RR.IdCheckDetail
	ORDER BY #RR.IdCheck DESC
	*/

	SELECT TOP 1
	  @RetDate = #RR.DateOfReject,
	  @RetReason = CASE WHEN LR.[Message] IS NULL THEN #RR.RTR_Name ELSE LR.[Message] END
	FROM #RR
	LEFT JOIN dbo.LenguageResource LR WITH (NOLOCK) ON LR.MessageKey = #RR.RRLangKey AND LR.IdLenguage = @IdLang
	ORDER BY #RR.IdCheck DESC;

	SELECT
		@IdIssuer [IdIssuer],
		@IssuerName [IssuerName],
		@TotProcessed [TotalProcessed],
		@TotRejected [TotalRejected],
		@RetDate [LastRejectionDate],
		@RetReason [LastRejectionReason];

END

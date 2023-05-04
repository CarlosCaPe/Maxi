CREATE PROCEDURE [Corp].[st_GetDuplicateCheckById_Checks]
	-- Add the parameters for the stored procedure here
	@CheckId INT
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="2020/01/02" Author="jgomez"> Fix:Ticket 2107: Incluir chques que no tengan fotos</log>
<log Date="2023/04/17" Author="cagarcia"> Fix:Ticket 8696 / BM-1808 Optimizacion en busqueda de cheques duplicados</log> 
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

BEGIN

	CREATE TABLE #TmpCheques(
		[IdCheck] int not null,
		[DateOfMovement] varchar(50),
		[FileName] varchar(250),
		Extension varchar(10),
		StatusName varchar(250),
		Description varchar(250),
		IdIssuer int)	

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
	declare @IssuerCheckPath varchar(max)= (select value from GlobalAttributes WITH(NOLOCK) where Name ='IssuerCheckPath')
	
	DECLARE	@CheckNumber varchar(25),@RoutingNumber varchar(50),@AcctNumber varchar(50);

	SELECT @CheckNumber = CheckNumber,@RoutingNumber = RoutingNumber,@AcctNumber = Account FROM dbo.Checks WITH (NOLOCK) WHERE IdCheck = @CheckId;

	DECLARE @IdCheck TABLE
	(
		IdCheck int
	);

	INSERT INTO @IdCheck
	SELECT IdCheck FROM dbo.Checks WITH (NOLOCK) WHERE CheckNumber = @CheckNumber AND RoutingNumber = @RoutingNumber AND Account = @AcctNumber AND IdCheck != @CheckId;
	
	IF EXISTS (SELECT 1 FROM @IdCheck)
	BEGIN
	
		INSERT INTO #TmpCheques
		SELECT
			C.[IdCheck]
			, C.[DateOfMovement]
			--, uf.FileName as FileName
			,CASE 
				WHEN CONCAT(@IssuerCheckPath, CONVERT(varchar(MAX),C.[IdIssuer]),'\Checks\', CONVERT(varchar(MAX),C.[IdCheck]),'\' + uf.[FileName]) IS NULL then 'IncluirCheques' 
				ELSE CONCAT(@IssuerCheckPath, CONVERT(varchar(MAX),C.[IdIssuer]),'\Checks\', CONVERT(varchar(MAX),C.[IdCheck]),'\' + uf.[FileName]) 
			END AS [FileName] 
			--@IssuerCheckPath+ convert(varchar(max),C.[IdIssuer])+'\Checks\'+ convert(varchar(max),C2.[IdCheck])+'\' + uf.FileName as FileName
			, uf.Extension
			, S.StatusName 
			, uf.LastCHange_LastNoteChange as [Description]
			, C.IdIssuer
			--, C2.[CheckNumber]
			--, C2.[RoutingNumber]
			--, C2.[Account]
		FROM [dbo].[Checks] C WITH (NOLOCK)
		LEFT JOIN dbo.UploadFiles uf WITH(NOLOCK) ON uf.IdReference= C.IdCheck AND uf.IdDocumentType = 69
		LEFT JOIN dbo.[Status] S WITH(NOLOCK) ON (s.IdStatus = C.IdStatus )
		WHERE EXISTS (SELECT 1 FROM @IdCheck AS I WHERE C.IdCheck = I.IdCheck)
		ORDER BY C.[DateOfMovement] DESC;

		SELECT 
			IdCheck,
			DateOfMovement,
			[FileName],
			Extension,
			StatusName,
			[Description],
			IdIssuer
		FROM #TmpCheques WITH (NOLOCK) WHERE [FileName] = 'IncluirCheques'
	
		UNION

		SELECT 
			IdCheck,
			DateOfMovement,
			[FileName],
			Extension,
			StatusName,
			[Description],
			IdIssuer
		FROM #TmpCheques WITH (NOLOCK) WHERE [Description] = 'This is the Front Img of check' ORDER BY DateOfMovement DESC

		DROP TABLE #TmpCheques
	
	END	
	
END


--SELECT
--		C2.[IdCheck]
--		, C2.[DateOfMovement]
--		--, C2.[CheckNumber]
--		--, C2.[RoutingNumber]
--		--, C2.[Account]
--	FROM
--	[dbo].[Checks] C WITH (NOLOCK)
--	JOIN [dbo].[Checks] C2 WITH (NOLOCK) ON C.[CheckNumber] = C2.[CheckNumber] AND C.[RoutingNumber] = C2.[RoutingNumber]
--											AND C.[Account] = C2.[Account]
--	WHERE C.[IdCheck] = @CheckId AND C2.[IdCheck] != @CheckId
--	ORDER BY C2.[DateOfMovement] DESC


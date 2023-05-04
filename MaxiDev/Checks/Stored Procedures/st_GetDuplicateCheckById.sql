-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-11-02
-- Description:	Get checks with same characteristics 
-- Author:		Dario Almeida
-- Create date: 2017-05-15
-- Description:	Nuevos Campos 
-- =============================================
CREATE PROCEDURE [Checks].[st_GetDuplicateCheckById]
	-- Add the parameters for the stored procedure here
	@CheckId INT
AS
/********************************************************************<Author> </Author><app></app><Description></Description><ChangeLog><log Date="20/12/2018" Author="jmolina">Add with(nolock)</log><log Date="2020/01/02" Author="jgomez"> Fix:Ticket 2107: Incluir chques que no tengan fotos</log></ChangeLog>*********************************************************************/

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

	
	INSERT INTO #TmpCheques
	SELECT
		C2.[IdCheck]
		, C2.[DateOfMovement]
		--, uf.FileName as FileName
		,CASE WHEN @IssuerCheckPath+ convert(varchar(max),C.[IdIssuer])+'\Checks\'+ convert(varchar(max),C2.[IdCheck])+'\' + uf.[FileName] IS NULL then 'IncluirCheques' else @IssuerCheckPath+ convert(varchar(max),C.[IdIssuer])+'\Checks\'+ convert(varchar(max),C2.[IdCheck])+'\' + uf.[FileName] END AS [FileName] 
		--@IssuerCheckPath+ convert(varchar(max),C.[IdIssuer])+'\Checks\'+ convert(varchar(max),C2.[IdCheck])+'\' + uf.FileName as FileName
		, uf.Extension
		, S.StatusName 
		, uf.LastCHange_LastNoteChange as [Description]
		, C.IdIssuer
		--, C2.[CheckNumber]
		--, C2.[RoutingNumber]
		--, C2.[Account]
	FROM
	[dbo].[Checks] C WITH (NOLOCK)
	JOIN [dbo].[Checks] C2 WITH (NOLOCK) ON C.[CheckNumber] = C2.[CheckNumber] 
											AND C.[RoutingNumber] = C2.[RoutingNumber]
											AND C.[Account] = C2.[Account]
	LEFT JOIN UploadFiles uf WITH (NOLOCK) ON uf.IdReference= C2.IdCheck
	LEFT JOIN [Status] S WITH (NOLOCK) ON (s.IdStatus = C2.IdStatus )
	WHERE C.[IdCheck] = @CheckId 
		AND C2.[IdCheck] != @CheckId
		--AND uf.IdReference=@IdCheck
		--AND uf.IdDocumentType=69
		--AND uf.LastCHange_LastNoteChange = 'This is the Front Img of check'
	ORDER BY C2.[DateOfMovement] DESC

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
-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-11-02
-- Description:	Get Check By Id, this stored is used in Corporate (Backoffice)
--<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
-- =============================================
CREATE PROCEDURE [Checks].[st_GetCheckById]
	-- Add the parameters for the stored procedure here
	@CheckId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		[C].[DateOfMovement] AS [DateOfMovement]
		, [C].[Name] AS [Name]
		, [C].[FirstLastName] AS [FirstLastName]
		, [C].[SecondLastName] AS [SecondLastName]
		, [C].[IdIssuer] AS [IdIssuer]
		, [C].[IssuerName] AS [IssuerName]
		, [C].[Account] AS [Account]
		, [C].[Amount] AS [Amount]
		, [S].[StatusName] as [StatusName]
		, [C].[IdIdentificationType] AS [IdentificationType]
		, [C].[CheckNumber] AS [CheckNumber]
		, [C].[RoutingNumber] AS [Route]
		, [C].[IdCheck] AS [Folio]
		, [A].[IdAgent] AS [IdAgent]
		, [A].[AgentName] AS [AgentName]
		, [A].[AgentCode] AS [AgentCode]
		, [C].[ClaimCheck] AS [ClaimCheck]
		, [C].[IdentificationNumber]
		, [C].[IdentificationDateOfExpiration]
		, [C].[SSNumber]
		, [C].[DateOfBirth]
		, [C].[CountryBirthId]
		, [C].[Ocupation]
		, [CU].[IdOccupation]
		, [CU].[IdSubcategoryOccupation]
		, [CU].[SubcategoryOccupationOther]
		, [C].[IdCustomer]
		, [C].[DateOfIssue]
		,ISNULL([C].[Fee],0) [Fee]
		,ISNULL([C].[Comission],0) [Comission]
        ,ISNULL([U].[UserName],'') [UserName]
		,ISNULL([UT].[Name],'') [UserType]
		 ,ISNULL(CPB.Name,'') CheckProcessorBank
	FROM
	[dbo].[Checks] AS [C] WITH (NOLOCK)
	INNER JOIN [dbo].[Customer] AS [CU] WITH (NOLOCK) ON [CU].[IdCustomer] = [C].[IdCustomer]
	INNER JOIN [dbo].[Agent] AS [A] WITH (NOLOCK) ON [C].[IdAgent] = [A].[IdAgent]
	INNER JOIN [dbo].[Status] AS [S] WITH (NOLOCK) ON [C].[IdStatus] = [S].[IdStatus]
	left join CheckProcessorBank CPB WITH (NOLOCK) on CPB.IdCheckProcessorBank=C.IdCheckProcessorBank
    LEFT JOIN [dbo].[Users] [U] WITH (NOLOCK) ON [C].[EnteredByIdUser] = [U].[IdUser]
	LEFT JOIN [dbo].[UsersType] [UT] WITH (NOLOCK) ON [U].[IdUserType] = [UT].[IdUserType] 
	WHERE
		[C].[IdCheck] = @CheckId

	EXEC [dbo].[st_GetSearchedCheckImageData] @CheckId

END



CREATE PROCEDURE [Corp].[st_GetCustomerIdentificationType]
	@GetDocumentImages BIT = 1
AS
-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-12-30
-- Description:	Return customer identification types and relationship with document images   
-- =============================================
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT Distinct
		[IdCustomerIdentificationType]
		, [Name]
		, [NameEs]
		, [RequireSSN]
		, [StateRequired]
		, [CountryRequired]
		--, ISNULL(DateOfBirthRequired,0)  DateOfBirthRequired
		FROM [dbo].[CustomerIdentificationType] i WITH(nolock)
		LEFT JOIN  [dbo].[CustomerIdentifTypeByCountry] cic WITH(NOLOCK) on i.IdCustomerIdentificationType = cic.IdDocument
        INNER JOIN [dbo].[Country] c WITH(NOLOCK) on cic.IdCountry = c.IdCountry

	IF @GetDocumentImages = 0
		RETURN

	SELECT
		C.[IdCustomerIdentificationType]
		, R.[IdDocumentImageType]
		, [dbo].[GetMessageFromMultiLenguajeResorces](1,DocumentImageCode) Name
		, [dbo].[GetMessageFromMultiLenguajeResorces](2,DocumentImageCode) NameEs
		--, ISNULL(C.DateOfBirthRequired,0)  DateOfBirthRequired
	FROM [dbo].[CustomerIdentificationType] C WITH(nolock)
	JOIN [dbo].[RelationDocumentImageType] R WITH(nolock) ON C.[IdCustomerIdentificationType] = R.[IdDocumentType]
	JOIN [dbo].[DocumentImageType] T WITH(nolock) ON T.[IdDocumentImageType] = R.[IdDocumentImageType]

END

CREATE PROCEDURE [Corp].[st_GetCustomerIdentificationType_Check]
	@GetDocumentImages 	BIT = 1,
	@IdCheck			INT = NULL
AS
-- =============================================
-- Author:		Cesar Garcia
-- Create date: 2020-12-04
-- Description:	  
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
        WHERE i.Active = 1
        UNION
        SELECT I.IdCustomerIdentificationType, I.Name, I.NameEs, I.RequireSSN, I.StateRequired, I.CountryRequired
        FROM dbo.CustomerIdentificationType I WITH(NOLOCK)
        JOIN dbo.Checks C WITH(NOLOCK) ON C.IdIdentificationType = I.IdCustomerIdentificationType
        WHERE C.IdCheck = @IdCheck       
        

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
	WHERE C.Active = 1
	UNION
	SELECT
		C.[IdCustomerIdentificationType]
		, R.[IdDocumentImageType]
		, [dbo].[GetMessageFromMultiLenguajeResorces](1,DocumentImageCode) Name
		, [dbo].[GetMessageFromMultiLenguajeResorces](2,DocumentImageCode) NameEs
	FROM [dbo].[CustomerIdentificationType] C WITH(nolock)
	JOIN [dbo].[RelationDocumentImageType] R WITH(nolock) ON C.[IdCustomerIdentificationType] = R.[IdDocumentType]
	JOIN [dbo].[DocumentImageType] T WITH(nolock) ON T.[IdDocumentImageType] = R.[IdDocumentImageType]
	JOIN dbo.Checks CHK WITH(NOLOCK) ON CHK.IdIdentificationType = C.IdCustomerIdentificationType
       	WHERE CHK.IdCheck = @IdCheck
	
	

END


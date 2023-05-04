﻿
CREATE PROCEDURE [dbo].[st_GetCustomerIdentificationType]
	@GetDocumentImages BIT = 1
AS
-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-12-30
-- Description:	Return customer identification types and relationship with document images   

-- Author:		Oscar Murillo
-- Create date: 2020-09-21
-- Description:	Return customer identification types and relationship with country

-- Author:		Julio Sierra
-- Create date: 2020-12-18
-- Description:	Show label (disabled / desactivado) in [CustomerIdentificationType] records with active equals to 0
-- =============================================
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
    Begin try
	SELECT Distinct
		IdCustomerIdentificationType, 
		CASE 
			WHEN i.Active = 1 THEN Name
			ELSE CONCAT(i.Name, ' (disabled)')
		END [Name],
		CASE 
			WHEN i.Active = 1 THEN NameEs
			ELSE CONCAT(i.NameEs, ' (desactivado)')
		END NameEs,
		RequireSSN, 
		StateRequired, 
		CountryRequired
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

	
	SELECT
		i.[IdCustomerIdentificationType]
		, cic.[IdCountry]
		FROM [dbo].[CustomerIdentificationType] i WITH(nolock)
		LEFT JOIN  [dbo].[CustomerIdentifTypeByCountry] cic WITH(NOLOCK) on i.IdCustomerIdentificationType = cic.IdDocument
		INNER JOIN [dbo].[Country] c WITH(NOLOCK) on cic.IdCountry = c.IdCountry
		
    End Try
  begin catch	  
	   Declare @ErrorMessage nvarchar(max);
	   Select @ErrorMessage=ERROR_MESSAGE();
	   Insert into [Maxi].dbo.ErrorLogForStoreProcedure  (StoreProcedure,ErrorDate,ErrorMessage)Values('[dbo].[st_GetCustomerIdentificationType]',Getdate(), @ErrorMessage);
  End Catch
    
END


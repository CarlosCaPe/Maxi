
/********************************************************************
<Author>omurillo</Author>
<app>Corporate </app>
<Description></Description>

<ChangeLog>
<log Date="15/09/2020" Author="omurillo"> obtener paises por identificacion </log>
</ChangeLog>

*********************************************************************/

CREATE PROCEDURE [dbo].[st_GetCountriesByIdType] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    Begin try
			SELECT cic.[IdIdentificationByCountry], cic.[IdDocument], cic.[IdCountry], c.[CountryName], c.[CountryCode]
			FROM [dbo].[CustomerIdentifTypeByCountry] cic WITH(NOLOCK)
			INNER JOIN [dbo].[Country] c WITH(NOLOCK) on cic.IdCountry = c.IdCountry
			INNER JOIN [dbo].[CustomerIdentificationType] cid WITH(NOLOCK) on cid.IdCustomerIdentificationType = cic.IdDocument
			ORDER BY [IdCountry]

    End Try
  begin catch	  
	   Declare @ErrorMessage nvarchar(max);
	   Select @ErrorMessage=ERROR_MESSAGE();
	   Insert into [Maxi].dbo.ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[dbo].[st_GetCountriesByIdType]',Getdate(), @ErrorMessage);
  End Catch
END
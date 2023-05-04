/********************************************************************
<Author>jresendiz</Author>
<app>Corporate </app>
<Description></Description>

<ChangeLog>
<log Date="26/12/2018" Author="jresendiz"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_GetIdentificationType] 
	@IdCustomerIdentificationType int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdCustomerIdentificationType], [Name], [RequireSSN], [StateRequired], [CountryRequired], [BTSIdentificationType]
      ,[BTSIdentificationIssuer], [NameEs], [ApprizaIdentificationType]
	FROM [dbo].[CustomerIdentificationType] WITH(NOLOCK)
	WHERE IdCustomerIdentificationType = @IdCustomerIdentificationType

END


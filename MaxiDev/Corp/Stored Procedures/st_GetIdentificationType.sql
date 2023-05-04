CREATE PROCEDURE [Corp].[st_GetIdentificationType] 
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

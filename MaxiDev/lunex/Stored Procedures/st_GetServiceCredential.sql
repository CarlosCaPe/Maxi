CREATE PROCEDURE [lunex].[st_GetServiceCredential]
(
    @Iduser int
)
AS
BEGIN

		SET NOCOUNT ON;

		SELECT [IdServiceCredential]
			  ,[AuthKey]
			  ,[Host]
			  ,[IpAddress]
			  ,[Realm]
			  ,[URL]
              ,isnull((select login from lunex.[login] where iduser=@Iduser and IdGenericStatus=1),'') loginLunex
		FROM [Lunex].[ServiceCredential]

END

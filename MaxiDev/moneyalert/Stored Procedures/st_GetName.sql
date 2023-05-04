CREATE PROCEDURE [MoneyAlert].[st_GetName]
(
@IdChat INT
)
AS
SET NOCOUNT ON
BEGIN TRY
      
Select B.Name from MoneyAlert.chat A
Join MoneyAlert.CustomerMobile B on (A.IdCustomerMobile=B.IdCustomerMobile)
Where A.IdChat=@IdChat
      
END TRY
BEGIN CATCH
       INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
       VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH


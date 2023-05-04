-- =============================================
-- Author:		Miguel Hinojo
-- Create date: 2016-11-03
-- Description:	Insert token ssecurity and get GUID 
-- =============================================
CREATE PROCEDURE [dbo].[st_GetTokenSecurity]
	@Token AS UNIQUEIDENTIFIER OUTPUT 
AS
BEGIN TRY
	SET NOCOUNT ON;
	DECLARE @TokenTemp AS UNIQUEIDENTIFIER
	SELECT @TokenTemp = NEWID();
	INSERT INTO [dbo].[TokenSecurity] ([Token], [CreationDate], [IsEnabled]) VALUES (@TokenTemp, GETDATE(), 1)
	SET @Token = @TokenTemp
END TRY
BEGIN CATCH
	SET @Token = '00000000-0000-0000-0000-000000000000'
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_GetTokenSecurity', GETDATE(), @ErrorMessage)
END CATCH



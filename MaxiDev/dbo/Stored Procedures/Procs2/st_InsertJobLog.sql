-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-12-10
-- Description:	Insert log for jobs 
-- =============================================
CREATE PROCEDURE [dbo].[st_InsertJobLog]
	-- Add the parameters for the stored procedure here
	@JobName NVARCHAR(MAX),
	@ReferenceId BIGINT = NULL,
	@Message NVARCHAR(MAX),
	@HasError BIT = 0
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[LogForJobProcess] ([JobName], [ReferenceId], [Message]) VALUES (@JobName, @ReferenceId, @Message)

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_InsertJobLog', GETDATE(), @ErrorMessage)
END CATCH

-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-12-07
-- Description:	Update a service configuration
-- =============================================
CREATE PROCEDURE [Services].[st_ServiceConfigurationSaveChanges]
	-- Add the parameters for the stored procedure here
	@Code NVARCHAR(MAX)
	, @LastTick DATETIME = NULL
	, @NextTick DATETIME = NULL
	, @IsEnabled BIT
	, @HasError BIT OUTPUT
	, @Message NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	UPDATE [Services].[ServiceConfiguration] SET [LastTick] = @LastTick, [NextTick] = @NextTick
	WHERE [Code] = @Code
	
	SET @Message = 'Done'
	SET @HasError = 0

END TRY
BEGIN CATCH
	SET @HasError=1                                                                                   
	SELECT @Message = 'Error trying save data'
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_ServiceConfigurationSaveChanges', GETDATE(), @ErrorMessage)
END CATCH

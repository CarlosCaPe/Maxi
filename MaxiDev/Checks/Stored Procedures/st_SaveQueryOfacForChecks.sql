-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-10-22
-- Description:	Save query ofac for checks
-- =============================================
CREATE PROCEDURE [Checks].[st_SaveQueryOfacForChecks]
	-- Add the parameters for the stored procedure here
	@CheckId INT,
	@EnteredByUserId INT,
	@AffectedRows BIT OUTPUT,
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @AffectedRows = 1

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[CheckOFACReview] WITH (NOLOCK) WHERE [IdCheck] = @CheckId AND [IdUserReview] = @EnteredByUserId)
		INSERT INTO [dbo].[CheckOFACReview] VALUES (@CheckId, @EnteredByUserId, GETDATE(), 1, '')
	ELSE
		SET @AffectedRows = 0

	SET @HasError = 0
	SET @Message = ''

END TRY
BEGIN CATCH
	SET @HasError = 1
	SELECT @Message = [dbo].[GetMessageFromLenguajeResorces] (0, 33)
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_SaveQueryOfacForChecks', GETDATE(), @ErrorMessage)
END CATCH

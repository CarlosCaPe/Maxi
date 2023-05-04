CREATE PROCEDURE dbo.FD_ResolveInquiryTicket
(
	@Id					INT,
	@ErrorResolution	BIT,
	@IdFileResolution	INT,
	@IdUser				INT
)
AS
BEGIN
	BEGIN TRY
		UPDATE dbo.FD_InquiryTicket SET
			ErrorResolution = @ErrorResolution,
			IdFileResolution = @IdFileResolution,
			ChangeByUser = @IdUser,
			ResolutionDate = GETDATE(),
			DateOfLastChange = GETDATE()
		WHERE Id = @Id
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(max) = ERROR_MESSAGE();
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		Values('[dbo].[FD_ResolveInquiryTicket]', Getdate(), @ErrorMessage);

		RAISERROR(@ErrorMessage, 16, 1);
	END CATCH
END
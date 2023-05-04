CREATE PROCEDURE dbo.FD_CreateInquiryTicket
(
	@Id						INT,
	@IdTransfer				INT,
	@IdUser					INT
)
AS
BEGIN
	BEGIN TRY
		INSERT INTO dbo.FD_InquiryTicket
		(
			Id, 
			IdTransfer, 
			SendInquiryLetter,
			EnterByIdUser, 
			CreateDate
		)
		VALUES
		(
			@Id,
			@IdTransfer,
			0,
			@IdUser,
			GETDATE()
		)
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(max) = ERROR_MESSAGE();
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		Values('[dbo].[FD_CreateInquiryTicket]', Getdate(), @ErrorMessage);

		RAISERROR(@ErrorMessage, 16, 1);
	END CATCH
END

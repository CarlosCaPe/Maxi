CREATE PROCEDURE dbo.FD_AddInquiryLetter
(
	@Id						INT,
	@IdFileInquiryLetter	INT,
	@CustomerEmail			VARCHAR(30),
	@InquiryReason			VARCHAR(500),
	@InquiryReasonENG		VARCHAR(500),
	@IdUser					INT
)
AS
/********************************************************************
<Author>Unknown</Author>
<app>Corporativo</app>
<Description>Crea carta para cliente</Description>

<ChangeLog>
<log Date="09/02/2023" Author="cagarcia">BM-522 Se agrega parametro InquiryReasonENG</log>
</ChangeLog>
*********************************************************************/
BEGIN
	BEGIN TRY
		UPDATE dbo.FD_InquiryTicket SET
			SendInquiryLetter = 1,
			IdFileInquiryLetter = @IdFileInquiryLetter,
			CustomerEmail = @CustomerEmail,
			InquiryReason = @InquiryReason,
			InquiryReasonENG = @InquiryReasonENG,
			ChangeByUser = @IdUser,
			DateOfLastChange = GETDATE()
		WHERE Id = @Id
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(max) = ERROR_MESSAGE();
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		Values('[dbo].[FD_AddInquiryLetter]', Getdate(), @ErrorMessage);

		RAISERROR(@ErrorMessage, 16, 1);
	END CATCH
END


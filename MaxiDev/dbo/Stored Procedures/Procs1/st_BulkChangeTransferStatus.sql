CREATE PROCEDURE [dbo].[st_BulkChangeTransferStatus]
(
	@IdGatewayUser	INT,
	@References		XML
)
AS
BEGIN
	DECLARE @ErrorMessage	NVARCHAR(500),
			@Success		BIT = 1

	DECLARE @InvalidTransfer	TABLE(ClaimCode NVARCHAR(200))
	DECLARE @Results			TABLE(Success BIT, MessageError NVARCHAR(500))
	DECLARE @TransferQueue		TABLE(
		IdReference				VARCHAR(200),
		ActionCode				VARCHAR(200),
		DateOfPayment			DATETIME,
		BranchCode				VARCHAR(200),
		BeneficiaryId			VARCHAR(200),
		BeneficiaryIdType		VARCHAR(200),
		Notes					VARCHAR(200)
	)

	DECLARE @IdGateway			INT

	SELECT
		@IdGateway = u.IdGateway
	FROM GatewayUser u 
	WHERE u.IdGatewayUser = @IdGatewayUser

	INSERT INTO @TransferQueue
	SELECT
		t.c.value('IdReference[1]', 'VARCHAR(200)'),
		t.c.value('ActionCode[1]', 'VARCHAR(200)'),
		t.c.value('DateOfPayment[1]', 'DATETIME'),
		t.c.value('BranchCode[1]', 'VARCHAR(200)'),
		t.c.value('BeneficiaryId[1]', 'VARCHAR(200)'),
		t.c.value('BeneficiaryIdType[1]', 'VARCHAR(200)'),
		t.c.value('Notes[1]', 'VARCHAR(200)')
	FROM @References.nodes('/root/Transfer') t(c)

	UPDATE @TransferQueue SET
		DateOfPayment = NULL
	WHERE DateOfPayment = CAST('' AS DATETIME)

	;WITH cteValidate AS
	(
		SELECT tq.IdReference FROM @TransferQueue tq
		EXCEPT
		SELECT 
			t.ClaimCode
		FROM Transfer t WITH (NOLOCK) 
		WHERE
			EXISTS (SELECT 1 FROM @TransferQueue tq WHERE tq.IdReference = t.ClaimCode)
			AND t.IdGateway = @IdGateway
	)
	INSERT INTO @InvalidTransfer(ClaimCode)
	SELECT c.IdReference FROM cteValidate c

	IF EXISTS (SELECT 1 FROM @InvalidTransfer)
	BEGIN
		SET @Success = 0
		SET @ErrorMessage = CONCAT(
			'The aggregator in session does not have transfers with IdReferences (',
			STUFF((SELECT ', ' + i.ClaimCode  FROM @InvalidTransfer i FOR XML PATH('')), 1, 2, ''),
			')'
		)
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			DECLARE @IdReference			VARCHAR(200),
					@ActionCode				VARCHAR(200),
					@DateOfPayment			DATETIME,
					@BranchCode				VARCHAR(200),
					@BeneficiaryId			VARCHAR(200),
					@BeneficiaryIdType		VARCHAR(200),
					@Notes					VARCHAR(200)

			WHILE EXISTS(SELECT 1 FROM @TransferQueue) AND @Success = 1
			BEGIN
				SELECT TOP 1
					@IdReference = tq.IdReference,
					@ActionCode = ActionCode,
					@DateOfPayment = DateOfPayment,
					@BranchCode = BranchCode,
					@BeneficiaryId = BeneficiaryId,
					@BeneficiaryIdType = BeneficiaryIdType,
					@Notes = Notes
				FROM @TransferQueue tq

				DELETE FROM @Results

				INSERT INTO @Results(Success, MessageError)
				EXEC st_ChangeTransferStatus @IdGatewayUser, 
					@IdReference, 
					@ActionCode, 
					@DateOfPayment, 
					@BranchCode, 
					@BeneficiaryId, 
					@BeneficiaryIdType, 
					@Notes

				IF EXISTS(SELECT 1 FROM @Results WHERE Success = 0)
					SET @Success = 0					

				DELETE TOP(1) FROM @TransferQueue
			END

			IF @Success = 0
			BEGIN
				SELECT
					@ErrorMessage = CONCAT(
						'An error occurred while the operation was being performed, no transactions changed state',
						CHAR(13)+CHAR(10),
						'Details:', 
						CHAR(13)+CHAR(10),
						'(', @IdReference, ') ', r.MessageError
					)
				FROM @Results r

				ROLLBACK TRANSACTION
			END
			ELSE
				COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			
			IF(ISNULL(@ErrorMessage, '') = '')
				SET @ErrorMessage = ERROR_MESSAGE();

			INSERT INTO ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage)
			Values('st_BulkChangeTransferStatus', GETDATE(), @ErrorMessage)

			SET @Success = 0
			SET @ErrorMessage = 'Internal database error'
		END CATCH
	END

	SELECT	@Success		Success,
			@ErrorMessage	Message
END
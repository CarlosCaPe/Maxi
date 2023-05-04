/********************************************************************
<Author>JCSierra</Author>
<Description></Description>

<ChangeLog>
<log Date="03/10/2023" Author="jcsierra">Create procedure</log>
<log Date="03/16/2023" Author="jcsierra">Fix messages</log>
</ChangeLog>
*********************************************************************/
CREATE   PROCEDURE [MoneyOrder].[st_ChangeMoneyOrderStatus]
(
	@IdSaleRecord		INT,
	@IdStatus			INT,
	@Notes				VARCHAR(500),
	@EnterByIdUser		INT,
	@IdLanguage			INT
)
AS
BEGIN
	DECLARE @Message NVARCHAR(500),
			@Success	BIT	= 1

	BEGIN TRY
		DECLARE @CurrentDate		DATETIME = GETDATE(),
				@CurrentIdStatus	INT

		SELECT 
			@CurrentIdStatus = sr.IdStatus 
		FROM MoneyOrder.SaleRecord sr WITH(NOLOCK) 
		WHERE sr.IdSaleRecord = @IdSaleRecord

		IF @IdStatus IS NULL
			SET @IdStatus = @CurrentIdStatus

		IF ISNULL(@Notes, '') = ''
		BEGIN 
			SET @Success = 0
			SET @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage, 'MoneyOrder.ChangeStatus.NoteMissing')
		END
		ELSE IF @IdStatus <> @CurrentIdStatus AND @CurrentIdStatus IN (76, 77) -- Clearing, Void
		BEGIN 
			SET @Success = 0
			SET @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage, 'MoneyOrder.ChangeStatus.EndStatus')
		END
			
		IF @Success = 1
		BEGIN
			IF @IdStatus <> @CurrentIdStatus
				UPDATE MoneyOrder.SaleRecord SET
					IdStatus = @IdStatus,
					DateOfLastChange = @CurrentDate
				WHERE IdSaleRecord = @IdSaleRecord

			INSERT INTO MoneyOrder.SaleRecordDetails(IdSaleRecord, IdStatus, DateOfMovement, Note, EnterByIdUser)
			VALUES
			(@IdSaleRecord, @IdStatus, @CurrentDate, @Notes, @EnterByIdUser)

			IF @IdStatus = 77 --Void
				EXEC MoneyOrder.st_CancelMoneyOrder @IdSaleRecord

			IF @IdStatus <> @CurrentIdStatus
				SET @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'MoneyOrder.ChangeStatus.Success')
			ELSE 
				SET @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericOkSave')
		END

		SELECT 
			@Success Success,
			@Message [Message]
	END TRY
	BEGIN CATCH
		IF(ISNULL(@Message, '') = '')
			SET @Message = ERROR_MESSAGE();

		SELECT 
			0 Success,
			dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericErrorSave') [Message]

		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) 
		VALUES(ERROR_PROCEDURE() ,GETDATE(), @Message);
	END CATCH
END
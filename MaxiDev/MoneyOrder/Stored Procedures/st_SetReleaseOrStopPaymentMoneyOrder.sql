/********************************************************************
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
	<log Date="03/08/2023" Author="jfresendiz">Se crea SP</log>
	<log Date="03/21/2023" Author="jcsierra">Se corrigen los mensajes</log>
</ChangeLog>
********************************************************************/
CREATE   PROCEDURE [MoneyOrder].[st_SetReleaseOrStopPaymentMoneyOrder]
(
	@IdSaleRecord		INT,
	@Notes				VARCHAR(500),
	@EnterByIdUser		INT,
	@IdLanguage			INT,
	@StatusToChange		NVARCHAR(50),
	@IsReleased 		INT,
	@HasError 			BIT OUTPUT,
	@Message 			NVARCHAR(MAX) OUTPUT
)
AS 
BEGIN
	BEGIN TRY
		SET @IdLanguage = 1
		DECLARE @CurrentDate DATETIME = GETDATE()
		DECLARE @IdStatus INT
		DECLARE @ChangeStatusResult TABLE (Success BIT, [Message] NVARCHAR(500))
		
		SELECT @IdStatus = IdStatus FROM Status WITH(NOLOCK) WHERE StatusName = @StatusToChange

		INSERT INTO @ChangeStatusResult(Success, [Message])
		EXEC [MoneyOrder].[st_ChangeMoneyOrderStatus] @IdSaleRecord, @IdStatus, @Notes, @EnterByIdUser, @IdLanguage


		IF EXISTS(SELECT 1 FROM @ChangeStatusResult WHERE Success = 1)
		BEGIN
			IF EXISTS (SELECT TOP 1 IdSaleRecordHold FROM MoneyOrder.SaleRecordHold WITH(NOLOCK) WHERE IdSaleRecord = @IdSaleRecord)
				UPDATE MoneyOrder.SaleRecordHold SET 
					IdStatus = @IdStatus, 
					IsReleased = @IsReleased, 
					DateOfLastChange = GETDATE()
				WHERE IdSaleRecord = @IdSaleRecord
			ELSE 
				INSERT INTO MoneyOrder.SaleRecordHold (IdSaleRecord, IdStatus, IsReleased, DateOfValidation, DateOfLastChange, EnterByIdUser)
				VALUES (@IdSaleRecord, @IdStatus, @IsReleased, GETDATE(), GETDATE(), @EnterByIdUser)
								
			UPDATE MoneyOrder.SaleRecord
			SET DateOfLastChange = GETDATE() 
			WHERE IdSaleRecord = @IdSaleRecord
		END

		SELECT TOP 1
			@HasError = ~c.Success,
			@Message = c.Message
		FROM @ChangeStatusResult c

	END TRY
	BEGIN CATCH
		SET @HasError = 1
		SET @Message = 'Error when trying to update money order'
		DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		VALUES('MoneyOrder.st_SetReleaseMoneyOrder',GETDATE(),@ErrorMessage)
	END CATCH
END

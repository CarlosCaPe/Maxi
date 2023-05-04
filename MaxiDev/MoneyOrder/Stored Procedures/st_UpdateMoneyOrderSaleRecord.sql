

CREATE     PROCEDURE [MoneyOrder].[st_UpdateMoneyOrderSaleRecord]   
	@Store NVARCHAR(MAX),
	@Sequence BIGINT,
	@ClearingDate DATETIME,
	@ClearingAmount MONEY
AS

/********************************************************************
<Author>Alejandro Cardenas</Author>
date>02/03/2023</date>
<app>MoneyOrderUpdate</app>
<Description>Sp que realiza la actualizacion del estado de Money Order e inserta detalles del  Update</Description>

<ChangeLog>
	<log Date="03/14/2023" Author="acardenas">Se crea procedure</log>
	<log Date="03/22/2023" Author="acardenas">Se corrige with(nolock)</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
		SET NOCOUNT ON;

		DECLARE @IdSaleRecord INT = 0;
		DECLARE @StatusClearing INT = 76;
		DECLARE @UserId INT = 0;

		SELECT  @IdSaleRecord = IdSaleRecord				
				FROM MoneyOrder.SaleRecord  sr WITH (NOLOCK)
				INNER JOIN dbo.Agent a WITH (NOLOCK) 
				ON SR.IdAgent = A.IdAgent
				WHERE A.AgentCode = @Store
				AND SR.SequenceNumber = @Sequence
				AND IdStatus <> @StatusClearing;

		SELECT  @UserId = [VALUE] 
				FROM dbo.GlobalAttributes WITH (NOLOCK)
		WHERE NAME = 'SystemUserID';

		IF (@IdSaleRecord > 0)
		BEGIN
			UPDATE MoneyOrder.SaleRecord 
			SET IdStatus = @StatusClearing
			WHERE IdSaleRecord = @IdSaleRecord;

			INSERT INTO MoneyOrder.SaleRecordDetails (IdSaleRecord,IdStatus,DateOfMovement,Note,EnterByIdUser) 
			VALUES (@IdSaleRecord,@StatusClearing, GETDATE(),'Updated by iCertify Notification',@UserId);
			
			IF NOT EXISTS (SELECT 1 FROM MoneyOrder.SaleRecordClearingInfo WITH (NOLOCK) WHERE IdSaleRecord = @IdSaleRecord)
			BEGIN
				INSERT INTO MoneyOrder.SaleRecordClearingInfo (IdSaleRecord,DateOfMovement,ClearingDate,ClearingAmount,EnterByIdUser)
				VALUES (@IdSaleRecord,GETDATE(),@ClearingDate,@ClearingAmount,@UserId);
			END;
		END;
END TRY
BEGIN CATCH
	DECLARE @Message varchar(max) = ERROR_MESSAGE()
	DECLARE @ErrorLine varchar(20) = CONVERT(VARCHAR(20), ERROR_LINE())
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_UpdateMoneyOrderSaleRecord', GETDATE(), 'Line: ' + @ErrorLine + '. ' + @Message)
END CATCH

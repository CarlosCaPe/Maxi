CREATE PROCEDURE [dbo].[st_getTransactionStatusbyTicket]
(
	@idticket INT
)
AS 
/********************************************************************
<Author>Fabián González</Author>
<app>Corporativo</app>
<Description>Obtiene estatus de la transferencia a partir de un ticket</Description>

<ChangeLog>
<log Date="21/02/2017" Author="fgonzalez"> Creación </log>
</ChangeLog>
*********************************************************************/
BEGIN 

	--Declarar variables a arrojar
	DECLARE @idStatus INT ,@Status VARCHAR(200),@IdProductType INT, @idTransfer INT,@idTransaction INT 

	BEGIN TRY 
		

		--Se obtienen los ids del ticket
		SELECT @IdProductType= IdProduct,@idTransaction =IdTransaction, @idTransfer = Convert(BIGINT,Reference) 
		FROM Tickets WHERE IdTicket = @idTicket
	
		--Si es un Billpayment Softgate
		IF @IdProductType IN (1) BEGIN 
			SELECT @idStatus=[Status], @Status=CASE [Status] WHEN 1 THEN 'Active' ELSE 'Cancelled' END FROM BillPaymentTransactions WITH (NOLOCK) WHERE IdBillPayment=@idTransfer
		END 
		--Billpayment Regalii o TopUp Regalii
		IF @IdProductType IN (14,17) BEGIN 
			SELECT @idStatus= idStatus from [Regalii].[TransferR] WITH (NOLOCK) WHERE IdProductTransfer=@idTransfer
		END 
		--Transfers
		IF @IdProductType IN (3) BEGIN 
			SELECT @idStatus = isnull(@idStatus,idStatus) FROM Transfer WITH (NOLOCK) WHERE IdTransfer =@idTransaction
			SELECT @idStatus = isnull(@idStatus,idStatus) FROM TransferClosed WITH (NOLOCK) WHERE IdTransferClosed =@idTransaction
		END 
		--Cheques
		IF @IdProductType IN (15) BEGIN 
			SELECT @idStatus= idStatus FROM Checks WITH (NOLOCK) WHERE IdCheck = @idTransfer
		END 
		
		--LD, Topup, Lunex , Mega etc..
		IF @IdProductType IN (5,7,9,10,11,13,16) BEGIN 
			SELECT @idStatus=idStatus FROM [operation].[producttransfer] WITH (NOLOCK) WHERE idotherproduct=@IdProductType AND IdProductTransfer=@idTransfer
		END 
		
		--Se obtiene el estatus texto si no se tiene
		IF isnull(@Status,'')='' AND @idStatus > 0 BEGIN 
			 SELECT @Status =StatusName FROM Status WITH (NOLOCK) WHERE idstatus=@idStatus
		END 
		
		--Se arrojan resultados	
		SELECT idStatus=@idStatus, StatusName=@Status

	END TRY
	BEGIN CATCH
	    DECLARE @ErrorMessage NVARCHAR(MAX)
	    SELECT @ErrorMessage=ERROR_MESSAGE()
	    INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_getTransactionStatusbyTicket', GETDATE(), @ErrorMessage)
	END CATCH

END 


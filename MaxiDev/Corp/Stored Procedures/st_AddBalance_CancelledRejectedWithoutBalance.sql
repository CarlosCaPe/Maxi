CREATE PROCEDURE Corp.st_AddBalance_CancelledRejectedWithoutBalance	
	@IdAgent	INT,
	@Folio		INT,
	@ClaimCode	VARCHAR(max),
	@HasError	BIT OUT,
	@Message	VARCHAR(MAX) OUT
AS
BEGIN

	DECLARE @IdTransfer INT, @IdStatus INT, @Time INT
	
	SET @IdTransfer = 0
	SET @HasError = 0
	
	IF EXISTS (SELECT * FROM dbo.[TransferClosed] WITH(nolock) WHERE (IdAgent = @IdAgent AND Folio = @Folio) OR (ClaimCode = @ClaimCode AND ClaimCode <> ''))
	BEGIN
		--SELECT 'Es TransferClosed'
		SELECT @IdTransfer = T.IdTransferClosed, 
			@IdStatus = T.IdStatus, 
			@Time = datediff(mi, T.DateOfTransfer, getdate()) 
		FROM dbo.[TransferClosed] T WITH(nolock) 
		WHERE (IdAgent = @IdAgent AND Folio = @Folio) 
			OR (ClaimCode = @ClaimCode AND ClaimCode <> '')
			
		--Si el envío aún se encuentra en la tabla de dbo.[TransferClosed] se mueve a [Transfer]	
		EXEC [dbo].[st_MoveBackTransfer] @IdTransfer
		
	
	END
	ELSE
	BEGIN
		--SELECT 'Es Transfer'
		SELECT @IdTransfer = T.IdTransfer, 
			@IdStatus = T.IdStatus, 
			@Time = datediff(mi, T.DateOfTransfer, getdate()) 
		FROM dbo.[Transfer] T WITH(nolock) 
		WHERE (IdAgent = @IdAgent AND Folio = @Folio) 
			OR (ClaimCode = @ClaimCode AND ClaimCode <> '')
	
	END			
	
	--SELECT @IdTransfer IdTransfer, @IdStatus IdStatus, @Time TimeFromCreation	
	
	IF(@IdTransfer = 0)
	BEGIN
		SELECT @Message = 'Could not find transfer, please verify.'
		SELECT @HasError = 1
		RETURN
	END
   

   	IF(@IdStatus = 31)
   	BEGIN
   	
   		IF NOT EXISTS(SELECT * FROM dbo.AgentBalance WITH(NOLOCK) WHERE IdTransfer = @IdTransfer AND TypeOfMovement = 'REJ')
   		BEGIN
   		
	   		-- PARA TRANFERENCIA RECHAZADA  --status 31
			EXEC st_RejectedCreditToAgentBalance @IdTransfer
			SELECT @Message = 'Balance registered successfully'
			SELECT @HasError = 0
			   	
		END 
		ELSE
		BEGIN
		
			SELECT @Message = 'Transfer already has balance register'
			SELECT @HasError = 0
			
		END
   	
   	END
   	ELSE
   	BEGIN
   		IF (@IdStatus = 22)
   		BEGIN
   			
   			IF NOT EXISTS(SELECT * FROM dbo.AgentBalance WITH(NOLOCK) WHERE IdTransfer = @IdTransfer AND TypeOfMovement = 'CANC')
	   		BEGIN
	   		
		   		IF (@Time < 30)
	   			BEGIN
	   				-- PARA CANCELACION TOTAL CON COMISION -- estatus 22 con menos de media hora en el DateOfTransfer y sin haber llegado al estatus "PaymentReady"
					EXEC st_CancelCreditToAgentBalanceTotalAmount @IdTransfer
					SELECT @Message = 'Balance registered successfully'
					SELECT @HasError = 0
	   			END
	   			ELSE
	   			BEGIN
	   				-- PARA CANCELACION TOTAL SIN COMISIONario-- estatus 22 con más de media hora en el DateOfTransfer o con menos de media hora pero que llegó al estatus "Payment Ready"
					EXEC st_CancelCreditToAgentBalance @IdTransfer  
					SELECT @Message = 'Balance registered successfully'
					SELECT @HasError = 0			
	   			END
				   	
			END 
			ELSE
			BEGIN
			
				SELECT @Message = 'Transfer already has balance register'
				SELECT @HasError = 0
				
			END   		
   		END 
   	END		   	
	
	
--	
--	SELECT * FROM TransferClosed WHERE IdTransferClosed = 48231714
-- 	SELECT IdStatus, * FROM Transfer WHERE IdTransfer = 48231714	
	
	
	
	
	
	
				

END
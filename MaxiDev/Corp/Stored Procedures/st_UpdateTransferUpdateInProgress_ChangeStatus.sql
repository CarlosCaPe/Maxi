CREATE PROCEDURE [Corp].[st_UpdateTransferUpdateInProgress_ChangeStatus]
	@ClaimCode	NVARCHAR(30),
	@IdStatus	INT = 0,
	@HasError 	BIT OUT,          
    @Message 	VARCHAR(max) OUT,
    @IsWarning	BIT OUT
AS
BEGIN
	
	BEGIN TRY
		/***Cambio de estatus a envíos en Update Transfer/Update In Progress***/
		--select idtransfer,idagent,folio,claimcode,DateofTransfer,idstatus,datestatuschange from dbo.[Transfer] with (nolock) where IdStatus in (70,71) and DATEDIFF(MINUTE,DateStatusChange,GETDATE())>=30
		
		--SELECT * FROM Status WHERE IdStatus IN (70,71)
		
		DECLARE @IdTransfer INT
		
		
		SELECT @IdTransfer = IdTransfer 
		FROM dbo.[Transfer] WITH (nolock) 
		WHERE ClaimCode = @ClaimCode
		
		IF (@IdStatus = 72)
		BEGIN
		
			IF (@IdTransfer IS NULL)
			BEGIN
				SELECT @IdTransfer = IdTransferClosed 
				FROM dbo.[TransferClosed] WITH(nolock) 
				WHERE ClaimCode = @ClaimCode
			END
			
			EXEC dbo.st_TransferModifyResponseGateway @IdTransfer, 1
		
			SET @HasError = 0
			SET @IsWarning = 0
			SET @Message = 'Transfer Status Updated Succesfully.'
		
		END
		ELSE
		BEGIN
		
			IF ((SELECT IdStatus FROM dbo.[Transfer] WITH (nolock) WHERE ClaimCode = @ClaimCode ) IN (70,71))
			BEGIN 		
			
				DECLARE @IdStatusToChange INT
				
				SET @IdStatusToChange = (SELECT TOP 1 IdStatus FROM dbo.TransferDetail WITH (nolock) WHERE IdTransfer = @IdTransfer AND IdStatus NOT IN (70,71) ORDER BY DateOfMovement DESC)		
			
				EXEC Soporte.sp_ChangeStatusTransaction @Claimcode, 'Cambio de estatus por error en sistema', @IdStatusToChange, 1
				
				SET @HasError = 0
				SET @IsWarning = 0
				SET @Message = 'Transfer Status Updated Succesfully.'
				--SELECT 'Test: Transfer Status Updated Succesfully.'
				
				
			END	
			ELSE 
			BEGIN
			
				
				SET @HasError = 0
				SET @IsWarning = 1
				SET @Message = 'Transfer already processed or out of COI Status, please verify.'
				--SELECT 'Test: Transfer already processed or out of COI Status, please verify.'
			
				--SELECT * FROM dbo.TransferDetail WITH (nolock) WHERE IdTransfer = @IdTransfer ORDER BY 1 DESC
				
			END
		
		END
		
		
	END TRY
	BEGIN CATCH  
		
		         
		Set @HasError=1          
		Select @Message = ERROR_MESSAGE()         
		Declare @ErrorMessage nvarchar(max)           
		Declare @ErrorLine nvarchar(max)
		Select @ErrorMessage=ERROR_MESSAGE()          
		Select @ErrorLine = CONVERT(VARCHAR(20), ERROR_LINE())
		
		--SELECT 'Catch', @ErrorMessage, @ErrorLine
		
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_UpdateTransfer_UpdateInProgress_ChangeStatus]',Getdate(), 'Line: ' + @ErrorLine + ', ' + @ErrorMessage)          
	END CATCH 

END




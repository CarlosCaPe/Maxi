CREATE procedure [dbo].[st_TransferToCancelInProgress]                
(                
    @EnterByIdUser int,                
    --@IsSpanishLanguage bit,                
    @IdLenguage int ,
    @IdTransfer int,                
    @Note nvarchar(max),    
    @IdReasonForCancel int,
	@IsDirectRefund30 bit,
    @HasError bit out,                
	@Message varchar(max) out
)                
AS    
 /********************************************************************
<Author>Not Known</Author>
<app>MaxiJobs</app>
<Description></Description>

<ChangeLog>
	<log Date="04/12/2018" Author="jmolina">Add WITH(NOLOCK)</log>
	<log Date="09/11/2020" Author="adominguez"> M00056 : Modificaciones</log>
	<log Date="27/04/2023" Author="maprado"> BM-1503 : parametro para cancelacion de nuevo flujo refunds</log>
</ChangeLog>
********************************************************************/
SET NOCOUNT ON   
BEGIN TRY
	DECLARE @IdStatus INT                
	DECLARE @IsValid BIT       
	DECLARE @IdPaymentType INT
	DECLARE @IdGateway INT
	DECLARE @ClaimCode NVARCHAR(100)
	DECLARE @ReasonEn NVARCHAR(MAX)
	DECLARE @ReasonEs NVARCHAR(MAX)
	DECLARE @IdAgent INT
	DECLARE @IdPaymentTypeDeposit INT    
	DECLARE @DateOfTransfer DATETIME
	DECLARE @DateStatusChange DATETIME
	DECLARE @HasErrorD BIT,	@MessageOutD VARCHAR(MAX)
	DECLARE @PendigByChangeRequestStatus INT
	DECLARE @StatusUpdateInProgress INT
	DECLARE @OriginalIdStatus INT
	DECLARE @IdStatusPendingPayment INT = 1

	--Modificar Para cualquier ambiente el id de status PendigByChangeRequest
	--QA = 75
	--Stage = ?
	--Prod = ?
	SET @PendigByChangeRequestStatus = 72
	--Modificar Para cualquier ambiente el id de status PendigByChangeRequest
	--QA = 73
	--Stage = ?
	--Prod = ?
	SET @StatusUpdateInProgress = 70

	SET @note = ISNULL(@Note,'')

	IF @IdLenguage IS NULL
		SET @IdLenguage=2

	SET @IdPaymentTypeDeposit =2    
     
	SELECT 
		@IdStatus = IdStatus, 
		@IdPaymentType = IdPaymentType, 
		@DateOfTransfer = DateOfTransfer,
		@IdGateway = IdGateway, 
		@ClaimCode = ClaimCode, 
		@IdAgent =IdAgent 
	FROM [Transfer] WITH(NOLOCK) 
	WHERE IdTransfer=@IdTransfer        

	DECLARE @ReturnAllComission INT

	SELECT @ReturnAllComission=ReturnAllComission, @ReasonEn=ReasonEn, @ReasonEs=Reason FROM ReasonForCancel WITH(NOLOCK) WHERE IdReasonForCancel=@IdReasonForCancel      

	SET @ReturnAllComission=isnull(@ReturnAllComission,0)

	IF @IdStatus = @StatusUpdateInProgress
	BEGIN
		SELECT @OriginalIdStatus = OriginalIdStatus FROM [dbo].[TransfersUpdateInProgress] WHERE IdTransfer=@IdTransfer --and IdUser=@EnterByIdUser
	END

	IF (@IdPaymentType=@IdPaymentTypeDeposit and (@IdStatus in (23,21) or (@IdStatus <> 20 AND DATEDIFF(MINUTE, @DateOfTransfer, GETDATE())>30)))
	BEGIN
		--SELECT  @Message=dbo.GetMessageFROMLenguajeResorces(@IsSpanishLanguage,53)                  
		SELECT @Message=[dbo].[GetMessageFROMMultiLenguajeResorces] (@IdLenguage,'MESSAGE53')
		SET @HasError=1   
		RETURN
	END
         
	DECLARE @XmlRules XML        
	SET @XmlRules='<Main><ValidStatus><Status>25</Status></ValidStatus>        
		<ValidStatus><Status>22</Status></ValidStatus></Main>'        
          
	EXEC IsValidIdStatusValidator @IdStatus,@XmlRules,@IsValid output        
      
	IF @IsValid=1                 
	BEGIN           
		IF @IdStatus=20 OR @IdStatus=41 OR @IdStatus=@PendigByChangeRequestStatus OR (@OriginalIdStatus in (20,41) and DATEDIFF(MINUTE, @DateOfTransfer, GETDATE())<30) 
		BEGIN
			SET @DateStatusChange = GETDATE()
			UPDATE [Transfer] SET IdStatus=22,DateStatusChange=@DateStatusChange,DateOfLastChange=@DateStatusChange,IdReasonForCancel=@IdReasonForCancel,IsRefunded=@IsDirectRefund30  WHERE IdTransfer=@IdTransfer and (IdStatus IN (20,41,40,24,23,@PendigByChangeRequestStatus) OR (@OriginalIdStatus in (20,41)))
			IF @@ROWCOUNT=1
			BEGIN               

				EXEC st_SaveChangesToTransferLog @IdTransfer,22,@Note,@EnterByIdUser       

				EXEC	[dbo].[st_DismissComplianceNotificationByIdTransfer]
	    		@IdTransfer,
				1,
				@HasErrorD OUTPUT,
				@MessageOutD OUTPUT

				IF (DATEDIFF(MINUTE, @DateOfTransfer, @DateStatusChange)<=30 OR @IdStatus in (71,40,23))
				BEGIN
						EXEC st_CancelCreditToAgentBalanceTotalAmount  @IdTransfer 
				END
				else
				BEGIN
				--EXEC st_CancelCreditToAgentBalance @IdTransfer       
					IF (@ReturnAllComission=1)--validar si se regresa completa la comision
						EXEC st_CancelCreditToAgentBalanceTotalAmount  @IdTransfer            
					else
						EXEC st_CancelCreditToAgentBalance @IdTransfer 
				END

				IF @IdStatus = @StatusUpdateInProgress
				BEGIN
					Insert into TransferModify (OldIdTransfer,NewIdTransfer,CreatedBy,CreateDate,OldIdStatus,IsCancel) values(@IdTransfer, 0, @EnterByIdUser, GETDATE(),@OriginalIdStatus, 1)
				END
          
			--    IF DATEDIFF(MINUTE, @DateOfTransfer, @DateStatusChange)>30
			--    BEGIN     
				--EXEC st_CancelCreditToAgentBalance  @IdTransfer  -- Adjust Agent Balance WITH one Credit       
			--    END
			--    ELSE
			--    BEGIN
			--      --regresar todo el dinero
			--      EXEC st_CancelCreditToAgentBalanceTotalAmount  @IdTransfer                    
			--    END  
				SELECT @Message=[dbo].[GetMessageFROMMultiLenguajeResorces] (@IdLenguage,'MESSAGE37')
				SET @HasError=0  
			END
		END
		ELSE IF (@IdStatus = @IdStatusPendingPayment)
		BEGIN
			SET @DateStatusChange = GETDATE()
			UPDATE [Transfer] SET 
				IdStatus = 22,
				DateStatusChange = @DateStatusChange,
				DateOfLastChange = @DateStatusChange,
				IdReasonForCancel = @IdReasonForCancel,
				IsRefunded = @IsDirectRefund30
			WHERE IdTransfer = @IdTransfer 
			AND IdStatus = @IdStatusPendingPayment

			EXEC st_SaveChangesToTransferLog @IdTransfer, 22, @Note, @EnterByIdUser
		END
		ELSE        
		BEGIN
			--stand by
			IF (@OriginalIdStatus in (20,3))
			BEGIN
				SELECT @Message=[dbo].[GetMessageFROMMultiLenguajeResorces] (@IdLenguage,'MESSAGE09')
				SET @HasError=1   
			END
			Else
			BEGIN
			
				UPDATE [Transfer] SET IdStatus=25,DateStatusChange=GETDATE(),IdReasonForCancel=@IdReasonForCancel, IsRefunded=@IsDirectRefund30 WHERE IdTransfer=@IdTransfer                    
				EXEC st_SaveChangesToTransferLog @IdTransfer,25,@Note,@EnterByIdUser  
	
				EXEC st_EmailCancelInProgress @ClaimCode, @IdTransfer, @IdGateway, @IdAgent, @ReasonEn, @ReasonEs

				IF @IdStatus = @StatusUpdateInProgress
				BEGIN
					Insert into TransferModify (OldIdTransfer,NewIdTransfer,CreatedBy,CreateDate,OldIdStatus,IsCancel) values(@IdTransfer, 0, @EnterByIdUser, GETDATE(),@OriginalIdStatus, 0)
				END
		    
				--SELECT  @Message=dbo.GetMessageFROMLenguajeResorces(@IsSpanishLanguage,8)      
				SELECT @Message=[dbo].[GetMessageFROMMultiLenguajeResorces] (@IdLenguage,'MESSAGE08')

				SET @HasError=0 
			END
		END                    
	END                
	ELSE                
	BEGIN
		SELECT @Message=[dbo].[GetMessageFROMMultiLenguajeResorces] (@IdLenguage,'MESSAGE09')
		SET @HasError=1                
	END
END TRY
BEGIN CATCH
	SET @HasError=1     
	SELECT @Message = [dbo].[GetMessageFROMMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
	DECLARE @ErrorMessage NVARCHAR(MAX)               
	SELECT @ErrorMessage = ERROR_MESSAGE()              
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES ('st_TransferToCancelInProgress', GETDATE(), @ErrorMessage)              
END CATCH

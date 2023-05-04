-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-04-19
-- Description:	Cancel Regalii TopUp Transaction
-- =============================================
CREATE PROCEDURE [Regalii].[st_CancelTopUpById]
	-- Add the parameters for the stored procedure here
	@IdLenguage INT,
    @EnterByIdUser INT,
    @IdProductTransfer BIGINT,
    @HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY
	
	DECLARE 
		@IdStatusOld INT,
		@IdStatus INT,
		@IdAgent INT,
		@Commission MONEY,
		@AgentCommission money,
		@CorpCommission money,    
		@IdAgentPaymentSchema int,    
		@IdOtherProduct int,
		@CancellationTimeStamp datetime,
		@login nvarchar(max)='',
		@TotalAmountToCorporate money,
		@ProductName NVARCHAR(1000),    
		@Phone NVARCHAR(1000),
		@TopupPhone NVARCHAR(1000),
		@Country NVARCHAR(MAX)

    SET @IdStatus=22 --Cancelled
	SELECT @login= [UserName] FROM [dbo].[Users] WITH (NOLOCK) WHERE [IdUser]=@EnterByIdUser

    SELECT          
        @IdAgent = PT.[IdAgent],
        @Commission = PT.[Commission],
        @AgentCommission = PT.[AgentCommission],
	    @CorpCommission =PT.[CorpCommission],
        @IdStatusOld=PT.[IdStatus],
        @IdOtherProduct=PT.[IdOtherProduct],
        @TotalAmountToCorporate=TR.[TotalAmountToCorporate],
        @TopupPhone=TR.[Account_Number],
        @Phone=TR.[CustomerCellPhoneNumber],
        @ProductName=TR.[Name]
    FROM [Operation].[ProductTransfer] PT WITH (NOLOCK)
    JOIN [Regalii].[TransferR] TR WITH (NOLOCK) ON PT.[IdProductTransfer]=TR.[IdProductTransfer]
    WHERE PT.[IdProductTransfer]=@IdProductTransfer
		/*and [action]=@Action*/
		AND PT.[IdStatus]=30
		
    --Verificar si se encontro la transferencia
    IF ISNULL(@IdAgent,0) = 0
    BEGIN
		SET @HasError=1
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
        RETURN
    END
    
    --Verificar si se encuentra en un status diferente a cancelado
    IF @IdStatusOld=22
    BEGIN    
        SET @HasError=1                                                                                    
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
        RETURN
    END
    
	SET @CancellationTimeStamp=GETDATE()

    EXEC	[Operation].[st_UpdateProductTransferStatus]
		    @IdProductTransfer = @IdProductTransfer,
		    @IdStatus = @IdStatus,
		    @TransactionDate = @CancellationTimeStamp,
            @EnterByIdUser = @EnterByIdUser,
		    @HasError = @HasError OUTPUT  
    
    UPDATE [Regalii].[TransferR] SET
        [IdStatus]=@IdStatus
		, [DateOfCancel] = @CancellationTimeStamp
		, [EnterByIdUserCancel]=@EnterByIdUser
	WHERE [IdProductTransfer]=@IdProductTransfer

    --Afectar Balance         

         EXEC	[dbo].[st_OtherProductToAgentBalance]
		    @IdTransaction = @IdProductTransfer,
		    @IdOtherProduct = @IdOtherProduct,
		    @IdAgent = @IdAgent,
		    @IsDebit = 0,
		    @Amount = @TotalAmountToCorporate,
		    @Description = @TopupPhone,
		    @Country = @ProductName,
		    @Commission = @Commission,
		    @AgentCommission = @AgentCommission,
		    @CorpCommission = @CorpCommission,
		    @FxFee = 0,
		    @Fee = 0,
		    @ProviderFee = 0
    
    Set @HasError=0 
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PTOK')
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                   
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('lunex.st_CancelProductTransferByIdUser',Getdate(),@ErrorMessage)                                                                                            
End Catch

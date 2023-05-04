-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-07
-- Description:	Register a Lunex product service // This stored is used in MaxiBackOffice (LunexWCFService)
-- =============================================
CREATE PROCEDURE [Lunex].[st_CancelTransferLN]
(
    @IdLenguage INT,
    @IdAgent INT,
    @EnterByIdUser INT,
    @Action NVARCHAR(MAX),
    @LNStatus NVARCHAR(1000),
    @TransactionID BIGINT,
    @TransactionCancelDate DATETIME,
    @SKU NVARCHAR(1000),
    @SKUType NVARCHAR(1000),
    @login NVARCHAR(MAX),
    @IdTransferLNOUT INT OUTPUT,
    @HasError INT OUTPUT,
    @Message VARCHAR(MAX) OUTPUT
)
AS
BEGIN TRY
	--Declaracion de variables
	DECLARE @IdStatus INT
			, @IdAgentPaymentSchema INT
			, @TotalAmountToCorporate MONEY = 0
			, @IdOtherProduct INT
			, @Amount MONEY
			, @Commission MONEY
			, @AgentCommission MONEY
			, @CorpCommission MONEY
			, @Description NVARCHAR(MAX)
			, @Country NVARCHAR(MAX)
			, @IdProductTransfer BIGINT

	IF @SKUType='Pinless' and @SKU='1021'
		SET @SKUType='PinlessU'

	SELECT @IdOtherProduct=[IdOtherProduct] FROM [Lunex].[SKUTypeToOtherProduct] WITH (NOLOCK) WHERE [SKUType]=@skutype

	IF @IdOtherProduct IS NULL
	BEGIN
		SET @HasError=8
		SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE38')
		RETURN
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[AgentUser] WITH (NOLOCK) WHERE [IdAgent]=@idagent)
	BEGIN
		SET @HasError=7                                                                                   
		SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE39')
		RETURN
	END
 

	--Inicializacion de Variables
	SET @IdStatus=22 --Cancelled   

	SELECT
		@IdTransferLNOUT = [IdTransferLN],
		@IdAgent = [IdAgent],
		@IdAgentPaymentSchema=[IdAgentPaymentSchema],
		@Amount = [Amount],
		@Commission = [Commission],
		@AgentCommission = [AgentCommission],
		@CorpCommission =[CorpCommission],
		@IdProductTransfer = [IdProductTransfer],
		@Description = CASE 
							WHEN [IdOtherProduct]=9 THEN [TopupPhone]
							WHEN IdOtherProduct=10 THEN [Phone]
							ELSE [SKUName]
							END,
		@Country = CASE
						WHEN [IdOtherProduct]=9 THEN [SKUName]
						WHEN [IdOtherProduct]=10 THEN [SKUName]
						ELSE ''                                                        
						END
	FROM [Lunex].[TransferLN] WITH (NOLOCK)
	WHERE [TransactionID]=@TransactionID
		AND [Action]=@Action
		AND [IdStatus]=30
		AND [IdOtherProduct]=@IdOtherProduct
		AND [IdAgent]=@idagent

	SET @IdTransferLNOUT=ISNULL(@IdTransferLNOUT,0)

	IF @IdTransferLNOUT=0
	BEGIN
		SET @HasError=12
		SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
		RETURN
	END

	DECLARE @IdSystemUser INT

	SELECT @IdSystemUser=dbo.GetGlobalAttributeByName('SystemUserID')

	EXEC [Operation].[st_UpdateProductTransferStatus]
					@IdProductTransfer = @IdProductTransfer,
					@IdStatus = @IdStatus,
					@TransactionDate = @TransactionCancelDate,
					@EnterByIdUser = @EnterByIdUser,
					@HasError = @HasError OUTPUT  


	IF @HasError=0
	BEGIN
		UPDATE [Lunex].[TransferLN]   SET 
										[LoginCancel] = @login
										,[TransactionCancelDate]=@TransactionCancelDate
										,[DateOfCancel] = GETDATE()
										,[LNStatus] = @LNStatus
										,[IdStatus] = @IdStatus
										,EnterByIdUserCancel=@EnterByIdUser
		WHERE IdTransferLN = @IdTransferLNOUT
      
        
		--calculos balance         
     
		IF @IdAgentPaymentSchema=2
			SET @TotalAmountToCorporate = @Amount-@AgentCommission
		ELSE
			SET @TotalAmountToCorporate = @Amount

		--Afectar Balance         

		EXEC	[dbo].[st_OtherProductToAgentBalance]
						@IdTransaction = @IdProductTransfer,
						@IdOtherProduct = @IdOtherProduct,
						@IdAgent = @IdAgent,
						@IsDebit = 0,
						@Amount = @TotalAmountToCorporate,
						@Description = @Description,
						@Country = @Country,
						@Commission = @Commission,
						@AgentCommission = @AgentCommission,
						@CorpCommission = @CorpCommission,
						@FxFee = 0,
						@Fee = 0,
						@ProviderFee = 0
	END
    
	SET @HasError=6
	SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE37')

END TRY
BEGIN CATCH
    SET @HasError=13
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
    DECLARE @ErrorMessage NVARCHAR(MAX)
    SELECT @ErrorMessage=ERROR_MESSAGE()
    INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('Lunex.st_CancelTransferLN', GETDATE(), @ErrorMessage)
END CATCH
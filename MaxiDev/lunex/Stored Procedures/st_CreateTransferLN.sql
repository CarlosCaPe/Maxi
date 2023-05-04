CREATE PROCEDURE [lunex].[st_CreateTransferLN]
(    
    @IdAgent INT,
    @EnterByIdUser INT,
	@Action NVARCHAR(MAX),
    @Login NVARCHAR(MAX),
	@Key BIGINT,
    @TransactionDate DATETIME,
    @TransactionID BIGINT,
    @CID NVARCHAR(1000),
    @Entity NVARCHAR(1000),
    @ExternalID NVARCHAR(1000),
    @SKU NVARCHAR(1000),
    @SKUName NVARCHAR(1000),
    @SKUType NVARCHAR(1000),
    @Phone NVARCHAR(1000),
    @TopupPhone NVARCHAR(1000),
    @Amount MONEY,
    @LNStatus NVARCHAR(1000),
    @D2Discount MONEY,
    @D1Discount MONEY,
    @R1Discount MONEY,
    @R2Discount MONEY,
    @Commission MONEY,
	@AgentCommission MONEY,
	@CorpCommission MONEY,
    @IdSchema INT,
    @IdLenguage INT,
    @Pin NVARCHAR(2000),
    @IdTransferLNOUT INT OUT,
    @HasError INT OUT,
    @Message VARCHAR(MAX) OUT,
    /*V2 Lunex*/    
	@ReceivedValue MONEY =NULL,
	@ReceivedCurrency NVARCHAR(1000) =NULL,			
	@SenderName NVARCHAR(1000) =NULL,
	@SenderAddress NVARCHAR(1000) =NULL,
	@SenderCity NVARCHAR(1000) =NULL,
	@SenderState NVARCHAR(1000) =NULL,	
	@AccessNumber NVARCHAR(1000) =NULL,	
	@ExpirationDate DATETIME =NULL,
	@Fee1 MONEY =NULL,
	@ExRate MONEY =NULL,
	@AmountInMN MONEY =NULL,
	@CountryCurrency NVARCHAR(MAX) =NULL
)
AS
/********************************************************************
<Author>Francisco Lara</Author>
<app> </app>
<Description>Register a Lunex product service // This stored is used in MaxiBackOffice (LunexWCFService) </Description>

<ChangeLog>
<log Date="2016-03-07" Author="flara"> Creacion  </log>
<log Date="2017-05-15" Author="dalmeida"> Agregar Fee desde el servicio </log>
<log Date="2017-06-26" Author="fgonzalez"> Agregar begin transaction al registrar transferencia </log>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>

*********************************************************************/
BEGIN TRY

	--INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) 
	--VALUES ('Lunex.st_CreateTransferLN', GETDATE(),'ExRate: '+ (CASE WHEN @ExRate IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR(MAX),@ExRate) END)+' - AmountInMN: '+(CASE WHEN @AmountInMN IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR(MAX),@AmountInMN) END)+' - CountryCurrency: '+(CASE WHEN @CountryCurrency IS NULL THEN 'NULL' ELSE @CountryCurrency END));
	--Declaracion de variables
	DECLARE @IdStatus INT
		, @IdAgentPaymentSchema INT
		, @TotalAmountToCorporate MONEY = 0
		, @IdOtherProduct INT
		, @IdProvider INT = 3
		, @IdAgentBalanceService INT
		, @IdProductTransfer BIGINT

	IF @SKUType='Pinless' and @SKU='1021'
		set @SKUType='PinlessU'

	SET @Fee1 = ISNULL(@Fee1,0)

	SELECT @IdOtherProduct=[IdOtherProduct] FROM [Lunex].[SKUTypeToOtherProduct] WITH (NOLOCK) WHERE [SKUType]=@skutype;

	IF @IdOtherProduct IS NULL
	BEGIN
		SET @HasError=8
		SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE38')
		RETURN
	END

	IF NOT EXISTS(SELECT 1 FROM [Lunex].[Product] WITH (NOLOCK) WHERE [SKU]=@sku) AND @SKUType in ('ITU','DTU')
	BEGIN
		SET @HasError=8
		SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE38')
		RETURN
	END

	IF NOT EXISTS(SELECT 1 FROM [dbo].[AgentUser] WHERE [IdUser]=@EnterByIdUser AND [IdAgent]=@IdAgent)
	BEGIN
		SET @HasError=7
		SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE39')
		RETURN
	END
 
	--Inicializacion de Variables
	SELECT @IdAgentBalanceService = [IdAgentBalanceService] FROM [dbo].[RelationAgentBalanceServiceOtherProduct] WITH (NOLOCK) WHERE [IdOtherProduct]=@IdOtherProduct
	SET @IdAgentBalanceService=ISNULL(@IdAgentBalanceService,6)
	SET @IdStatus=30 --Paid
	SELECT @IdAgentPaymentSchema=[IdAgentPaymentSchema] FROM [dbo].[Agent] WITH (NOLOCK) WHERE [IdAgent]=@IdAgent

	--calculos balance
	IF @IdAgentPaymentSchema=2
		SET @TotalAmountToCorporate = @Amount+@Fee1-@AgentCommission
	ELSE
		SET @TotalAmountToCorporate = @Amount+@Fee1

	--IF ISNULL(@TransactionID,0)>0 AND NOT EXISTS(SELECT TOP 1 [IdTransferLN] FROM [Lunex].[TransferLN] WITH (NOLOCK) WHERE [TransactionID]=@TransactionID AND [IdOtherProduct]=@IdOtherProduct)
	IF ISNULL(@TransactionID,0)>0 
	   AND NOT EXISTS(SELECT [IdTransferLN] FROM [Lunex].[TransferLN] with(nolock) WHERE [TransactionID]=@TransactionID AND [IdOtherProduct]=@IdOtherProduct)
	   AND NOT EXISTS(SELECT [IdProductTransfer] FROM [Operation].[ProductTransfer] with(nolock) WHERE [TransactionProviderID]=@TransactionID AND [IdOtherProduct]=@IdOtherProduct)
	BEGIN
	
	BEGIN TRY
           
        BEGIN TRANSACTION 
           
		EXEC [Operation].[st_CreateProductTransfer]
			@IdProvider = @IdProvider,
			@IdAgentBalanceService = @IdAgentBalanceService,
			@IdOtherProduct = @IdOtherProduct,
			@IdAgent = @IdAgent,
			@IdAgentPaymentSchema = @IdAgentPaymentSchema,
			@TotalAmountToCorporate = @TotalAmountToCorporate,
			@Amount = @Amount,
			@Commission = @Commission,
			@fee = @Fee1,
			@TransactionFee = 0,
			@AgentCommission = @AgentCommission,
			@CorpCommission = @CorpCommission,
			@EnterByIdUser = @EnterByIdUser,
			@TransactionDate = @TransactionDate,
			@TransactionID = @TransactionID,
			@HasError = @HasError OUTPUT,
			@IdProductTransferOut = @IdProductTransfer OUTPUT;
			
		        
			IF @HasError=0             
			BEGIN
				INSERT INTO [Lunex].[TransferLN]
						   ([IdOtherProduct]
						   ,[IdAgent]
						   ,[EnterByIdUser]
						   ,[Action]
						   ,[Login]
						   ,[LoginCancel]
						   ,[Key]
						   ,[DateOfCreation]           
						   ,[TransactionDate]
						   ,[TransactionID]
						   ,[CID]
						   ,[Entity]
						   ,[ExternalID]
						   ,[SKU]
						   ,[SKUName]
						   ,[SKUType]
						   ,[Phone]
						   ,[TopupPhone]
						   ,[Amount]
						   ,[LNStatus]
						   ,[IdStatus]
						   ,[D2Discount]
						   ,[D1Discount]
						   ,[R1Discount]
						   ,[R2Discount]
						   ,[Commission]
						   ,[AgentCommission]
						   ,[CorpCommission]
						   ,[IdAgentPaymentSchema]
						   ,[IdSchema]
						   ,[IdProductTransfer]
						   ,[Pin]
						   ,[ReceivedValue]
						   ,[ReceivedCurrency]
						   ,[SenderName]
						   ,[SenderAddress]
						   ,[SenderCity]
						   ,[SenderState]
						   ,[AccessNumber]
						   ,[ExpirationDate]
						   ,[Fee]
						   ,[ExRate]
						   ,[AmountInMN]
						   ,[CountryCurrency]
						   )
					 VALUES
						   (@IdOtherProduct
						   ,@IdAgent
						   ,@EnterByIdUser
						   ,@Action
						   ,@Login
						   ,''
						   ,@Key
						   ,GETDATE()           
						   ,@TransactionDate
						   ,@TransactionID
						   ,@CID
						   ,@Entity
						   ,@ExternalID
						   ,@SKU
						   ,@SKUName
						   ,@SKUType
						   ,@Phone
						   ,@TopupPhone
						   ,@Amount
						   ,@LNStatus
						   ,@IdStatus
						   ,@D2Discount
						   ,@D1Discount
						   ,@R1Discount
						   ,@R2Discount
						   ,@Commission
						   ,@AgentCommission
						   ,@CorpCommission
						   ,@IdAgentPaymentSchema
						   ,@IdSchema
						   ,@IdProductTransfer
						   ,@Pin               
						   ,@ReceivedValue	           
						   ,@ReceivedCurrency	           	           
						   ,@SenderName
						   ,@SenderAddress
						   ,@SenderCity
						   ,@SenderState	           
						   ,@AccessNumber	           
						   ,@ExpirationDate
						   ,@Fee1
						   ,@ExRate
						   ,@AmountInMN 
						   ,@CountryCurrency
						   );
	
				SET @IdTransferLNOUT=SCOPE_IDENTITY();
	
				DECLARE @Description NVARCHAR(MAX)
				DECLARE @Country NVARCHAR(MAX)
	
				SET @Description = CASE
									WHEN @IdOtherProduct=9 THEN @TopupPhone
									WHEN @IdOtherProduct=10 THEN @Phone
									ELSE @skuname
									END
	
				SET @Country = CASE
									WHEN @IdOtherProduct=9 THEN @skuname
									WHEN @IdOtherProduct=10 THEN @skuname
									ELSE ''
									END
	           
				DECLARE @TempProviderFee money= 0
				IF @Fee1 > 0 
					BEGIN
						SET @TempProviderFee = @Fee1 - @AgentCommission - @CorpCommission
					END

				IF @Fee1 > 0 and @SKU='9605'
					begin
						set @TempProviderFee=0
					end
	
				EXEC [dbo].[st_OtherProductToAgentBalance]
							@IdTransaction = @IdProductTransfer,
							@IdOtherProduct = @IdOtherProduct,
							@IdAgent = @IdAgent,
							@IsDebit = 1,
							@Amount = @TotalAmountToCorporate,
							@Description = @Description,
							@Country = @Country,
							@Commission = @Commission,
							@AgentCommission = @AgentCommission,
							@CorpCommission = @CorpCommission,
							@FxFee = 0,
							@Fee = @Fee1,
							@ProviderFee = @TempProviderFee;
	
				EXEC [Operation].[st_SaveChangesToProductTransferLog]
				@IdProductTransfer = @IdProductTransfer,
				@IdStatus = 1,
				@Note = 'Transfer Charge Added to Agent Balance',
				@IdUser = 0,
				@CreateNote = 0;
	                
	                
				EXEC [Operation].[st_UpdateProductTransferStatus]
								@IdProductTransfer = @IdProductTransfer,
								@IdStatus = @IdStatus,
								@TransactionDate = @TransactionDate,
								@HasError = @HasError OUTPUT ;     
	
				SET @HasError=1
				SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')
	
				IF @LNStatus='VOID'
					EXEC	[Lunex].[st_CancelTransferLN]
					@IdLenguage = @IdLenguage,
					@IdAgent = @IdAgent,
					@EnterByIdUser=@EnterByIdUser,
					@Action = @Action,
					@LNStatus = @LNStatus,
					@TransactionID = @TransactionID,
					@TransactionCancelDate = @TransactionDate,
					@SKU = @SKU,
					@SKUType = @SKUType,
					@login = @login,
					@IdTransferLNOUT = @IdTransferLNOUT OUTPUT,
					@HasError = @HasError OUTPUT,
					@Message = @Message OUTPUT;
		   
		
				COMMIT TRANSACTION
			END 	
			ELSE BEGIN 
				ROLLBACK TRANSACTION
			END 
		   	
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
	    END CATCH
	     
	END
	ELSE
	BEGIN
		SET @HasError=2
		SELECT @Message= 'El TransactionID ' + CONVERT(NVARCHAR(MAX),@TransactionID) + ' ya existe en el sistema, se intentaba insertar otra vez'

		DECLARE @Parameters XML=(
		SELECT
			ISNULL(CONVERT(Varchar(max),@IdAgent),'--NULL--') AS IdAgent,
			ISNULL(CONVERT(Varchar(max),@EnterByIdUser),'--NULL--') AS EnterByIdUser,
			ISNULL(CONVERT(Varchar(max),@Action),'--NULL--') AS [Action],	
			ISNULL(CONVERT(Varchar(max),@Login),'--NULL--') AS [Login],
			ISNULL(CONVERT(Varchar(max),@Key),'--NULL--') AS [Key],
			ISNULL(CONVERT(Varchar(max),@TransactionDate),'--NULL--') AS TransactionDate,
			ISNULL(CONVERT(Varchar(max),@TransactionID),'--NULL--') AS TransactionID,
			ISNULL(CONVERT(Varchar(max),@CID),'--NULL--') AS CID,
			ISNULL(CONVERT(Varchar(max),@SKU),'--NULL--') AS SKU,
			ISNULL(CONVERT(Varchar(max),@SKUType),'--NULL--') AS SKUType,
			ISNULL(CONVERT(Varchar(max),@Phone),'--NULL--') AS Phone,
			ISNULL(CONVERT(Varchar(max),@TopupPhone),'--NULL--') AS TopupPhone,
			ISNULL(CONVERT(Varchar(max),@Amount),'--NULL--') AS Amount,
			ISNULL(CONVERT(Varchar(max),@LNStatus),'--NULL--') AS LNStatus,
			ISNULL(CONVERT(Varchar(max),@IdSchema),'--NULL--') AS IdSchema,
			ISNULL(CONVERT(Varchar(max),@IdLenguage),'--NULL--') AS IdLenguage,
			ISNULL(CONVERT(Varchar(max),@Pin),'--NULL--') AS Pin,

			ISNULL(CONVERT(Varchar(max),@IdOtherProduct),'--NULL--') AS IdOtherProduct,

			ISNULL(CONVERT(Varchar(max),@IdTransferLNOUT),'--NULL--') AS IdTransferLNOUT,
			ISNULL(CONVERT(Varchar(max),@HasError),'--NULL--') AS HasError,
			ISNULL(CONVERT(Varchar(max),@Message),'--NULL--') AS [Message]						
		FOR
		XML PATH('RootXml'),TYPE);
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('Lunex.st_CreateTransferLN', GETDATE(), @Message + CONVERT(NVARCHAR(MAX),@Parameters));

	END
END TRY
BEGIN CATCH
    SET @HasError=3
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
    DECLARE @ErrorMessage NVARCHAR(MAX)
    SELECT @ErrorMessage=ERROR_MESSAGE()
    --INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('Lunex.st_CreateTransferLN', GETDATE(),@ErrorMessage)

	DECLARE @ErrorParameters XML=(
		SELECT
			ISNULL(CONVERT(Varchar(max),@IdAgent),'--NULL--') AS IdAgent,
			ISNULL(CONVERT(Varchar(max),@EnterByIdUser),'--NULL--') AS EnterByIdUser,
			ISNULL(CONVERT(Varchar(max),@Action),'--NULL--') AS [Action],	
			ISNULL(CONVERT(Varchar(max),@Login),'--NULL--') AS [Login],
			ISNULL(CONVERT(Varchar(max),@Key),'--NULL--') AS [Key],
			ISNULL(CONVERT(Varchar(max),@TransactionDate),'--NULL--') AS TransactionDate,
			ISNULL(CONVERT(Varchar(max),@TransactionID),'--NULL--') AS TransactionID,
			ISNULL(CONVERT(Varchar(max),@CID),'--NULL--') AS CID,
			ISNULL(CONVERT(Varchar(max),@SKU),'--NULL--') AS SKU,
			ISNULL(CONVERT(Varchar(max),@SKUType),'--NULL--') AS SKUType,
			ISNULL(CONVERT(Varchar(max),@Phone),'--NULL--') AS Phone,
			ISNULL(CONVERT(Varchar(max),@TopupPhone),'--NULL--') AS TopupPhone,
			ISNULL(CONVERT(Varchar(max),@Amount),'--NULL--') AS Amount,
			ISNULL(CONVERT(Varchar(max),@LNStatus),'--NULL--') AS LNStatus,
			ISNULL(CONVERT(Varchar(max),@IdSchema),'--NULL--') AS IdSchema,
			ISNULL(CONVERT(Varchar(max),@IdLenguage),'--NULL--') AS IdLenguage,
			ISNULL(CONVERT(Varchar(max),@Pin),'--NULL--') AS Pin,

			ISNULL(CONVERT(Varchar(max),@IdTransferLNOUT),'--NULL--') AS IdTransferLNOUT,
			ISNULL(CONVERT(Varchar(max),@HasError),'--NULL--') AS HasError,
			ISNULL(CONVERT(Varchar(max),@Message),'--NULL--') AS [Message],

			ISNULL(CONVERT(Varchar(max),@ErrorMessage),'--NULL--') AS [ErrorMessage]			
		FOR
		XML PATH('RootXml'),TYPE);
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('Lunex.st_CreateTransferLN', GETDATE(),CONVERT(NVARCHAR(MAX),@ErrorParameters));

END CATCH
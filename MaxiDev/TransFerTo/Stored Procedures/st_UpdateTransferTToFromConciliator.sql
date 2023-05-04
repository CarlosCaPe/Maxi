CREATE PROCEDURE [TransFerTo].[st_UpdateTransferTToFromConciliator]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Begin Try

Declare @HasError int = 0;
Declare @Message varchar(max);
/*--------------------------*/

	DECLARE @LastTime INT = 2;

	DECLARE @Transfer TABLE
	(
		Id INT IDENTITY(1,1),
		IdAgent Int,
		IdProductTransfer Int,
		DateOfCreation DateTime,
		DateOfStatusChange DateTime,
		IdOtherProduct Int,

		IdTransactionTTo Int,
		IdTransferTTo Int,
		DateOfCreatioTTo DateTime,
		Destination_Msisdn nvarchar(max),
		Country nvarchar(max),
		WholeSalePrice money,
		RetailPrice money,
		Commission money,
		AgentCommission money,
		CorpCommission money,
		Operator nvarchar(max),

		IdProductTransferDetail Int,
		DateOfMovement DateTime,
		Debit Bit Default((0)),
		Credit Bit Default((0))
	)

	/*Transacciones en estado Cancelado de Trasnfer To*/
	INSERT INTO @Transfer 
	(	IdAgent,
		IdProductTransfer, 
		DateOfCreation,
		DateOfStatusChange,
		PT.IdOtherProduct, 

		IdTransactionTTo,
		IdTransferTTo,
		DateOfCreatioTTo,
		Destination_Msisdn,
		Country,
		WholeSalePrice,
		RetailPrice,
		Commission,
		AgentCommission,
		CorpCommission,
		Operator,

		IdProductTransferDetail,
		DateOfMovement)
	SELECT 
		PT.IdAgent,
		PT.IdProductTransfer,
		PT.DateOfCreation,
		PT.DateOfStatusChange,
		PT.IdOtherProduct, 

		TT.IdTransactionTTo,
		TT.IdTransferTTo,
		TT.DateOfCreation AS DateOfCreatioTTo,
		TT.Destination_Msisdn,
		TT.Country,
		TT.WholeSalePrice,
		TT.RetailPrice,
		TT.Commission,
		TT.AgentCommission,
		TT.CorpCommission,
		TT.Operator,

		PTD.IdProductTransferDetail,
		PTD.DateOfMovement
	FROM Operation.ProductTransfer AS PT WITH(NOLOCK) 
		INNER JOIN TransFerTo.TransferTTo AS TT WITH(NOLOCK) On PT.IdProductTransfer = TT.IdProductTransfer
		INNER JOIN Operation.ProductTransferDetail AS PTD WITH(NOLOCK) ON PT.IdProductTransfer = PTD.IdProductTransfer
	WHERE PT.IdOtherProduct = 7 
	AND PT.IdStatus = 22 AND PTD.IdStatus = 22
	AND DATEDIFF(HOUR, TT.DateOfCreation, GETDATE()) < @LastTime;

	/*Se buscan las afectaciones(CTTU -> Credit, TTU -> Debit) de balance de las transferencias*/
	Update T
	Set 
		T.Credit = 1
	From AgentBalance AS AB WITH(NOLOCK) 
		INNER JOIN @Transfer AS T ON  AB.IdAgent = T.IdAgent AND AB.IdTransfer = T.IdProductTransfer
	Where TypeOfMovement = 'CTTU';
	--And AB.DateOfMovement >= T.DateOfCreatioTTo;

	Update T
	Set 
		T.Debit = 1	
	From AgentBalance AS AB WITH(NOLOCK) 
		INNER JOIN @Transfer AS T ON  AB.IdAgent = T.IdAgent AND AB.IdTransfer = T.IdProductTransfer
	Where TypeOfMovement = 'TTU';
	--And AB.DateOfMovement >= T.DateOfCreatioTTo;

	/*Se descartan transferencias con afectacion completa*/
	DELETE FROM @Transfer WHERE Credit = 1 AND Debit = 1;

	/*Caso 1: Trasnferencias con afectaciones incompletas (Credit = 0)*/
	DECLARE
		@Id Int,
		@IdProductTransfer int,
		@IdOtherProduct int;

	DECLARE
		@IdAgent int,    
		@Destination_Msisdn nvarchar(max),
		@Operator nvarchar(max),
		@Country nvarchar(max),
		@Commission money,
		@AgentCommission money,
		@CorpCommission money,
		@WholeSalePrice money,
		@RetailPrice money,
		@IdAgentPaymentSchema int;

	declare @CountryCode nvarchar(max);
	declare @IsDebit bit = 0;

	WHILE EXISTS(SELECT 1 FROM @Transfer WHERE Credit = 0)
	BEGIN

		SELECT TOP 1
				@Id = Id,
				@IdProductTransfer = IdProductTransfer,
				@IdOtherProduct = IdOtherProduct,
				@IdAgent = IdAgent,        
				@Destination_Msisdn = Destination_Msisdn,
				@Country = Country,
				@WholeSalePrice = WholeSalePrice,
				@RetailPrice = RetailPrice,
				@Commission = Commission,
				@AgentCommission = AgentCommission,
				@CorpCommission =CorpCommission  ,
				@Operator=Operator    
		FROM @Transfer
			WHERE Credit = 0;

		 --calculos balance
		select @IdAgentPaymentSchema=IdAgentPaymentSchema from agent where idagent=@IdAgent;
		declare @TotalAmountToCorporate money = 0;

		if (@IdAgentPaymentSchema=2)
			set @TotalAmountToCorporate = @WholeSalePrice + @CorpCommission;
		else
			set @TotalAmountToCorporate = @RetailPrice;

		--Afectar Balance
		select @CountryCode=CountryCode from TransferTo.Country where countryname = @Country;

		set @Country=upper(@Country);

		set @CountryCode= isnull(@CountryCode,@Country);

		EXEC [dbo].[st_OtherProductToAgentBalance]
			@IdTransaction = @IdProductTransfer,
			@IdOtherProduct = @IdOtherProduct,
			@IdAgent = @IdAgent,
			@IsDebit = 0,
			@Amount = @TotalAmountToCorporate,
			@Description = @Destination_Msisdn,
			@Country = @Operator,
			@Commission = @Commission,
			@AgentCommission = @AgentCommission,
			@CorpCommission = @CorpCommission,
			@FxFee = 0,
			@Fee = 0,
			@ProviderFee = 0;

		DELETE FROM @Transfer WHERE  @Id = Id;

		/*Registro de eventos*/
		SET @Message = 'Cancellation reconciliation record:IdProductTransfer('+CONVERT(VARCHAR(12),@IdProductTransfer)+'),IdAgent('+CONVERT(VARCHAR(12),@IdAgent)+')';
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_UpdateTransferTToFromConciliator',Getdate(),@Message)                                                                                            

	END

/*--------------------------*/
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                         
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE07')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_UpdateTransferTToFromConciliator',Getdate(),@ErrorMessage)                                                                                            
End Catch  

END

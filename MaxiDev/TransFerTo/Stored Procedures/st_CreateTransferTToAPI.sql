/********************************************************************
<Author>Unknow</Author>
<app>Agent</app>
<Description></Description>

<ChangeLog>
	<log Date="18/01/2018" Author="azavala">Optimizacion Agente : Se agregaron nuevos parametros de salida necesarios para actualizacion de Customer en ElasticSearch</log>
</ChangeLog>
*********************************************************************/
CREATE procedure [TransferTo].[st_CreateTransferTToAPI]
(    
    @IdLenguage int,
    @IdAgent int,
    @IdOtherProduct int,
    @Action nvarchar(max),
    @Key bigint,
    @Msisdn nvarchar(max),
    @Destination_Msisdn nvarchar(max),
    @Product nvarchar(max),
    @Operator nvarchar(max),
    @OriginCurrency nvarchar(max),
    @DestinationCurrency nvarchar(max),
    @WholeSalePrice money,
    @RetailPrice money,    
    @Country nvarchar(max),
    @Commission money,    
    @AgentCommission money,
    @CorpCommission money,    
    @IdSchema int,
    @EnterByIdUser int,
    @IdCustomer int,
    @IdCustomerFrequentNumber int,
    @NickName nvarchar(max),    
    @SaveCustomerFrequentNumber bit,
	@Name nvarchar(max),	--customer name
	@FirstLastName nvarchar(max), --customer last name
	@SecondLastName nvarchar(max), --customer second last name    
    @Request nvarchar(max), 
    --@IdTransferTTo int out,
    @IdProductTransferOut bigint out,
    @HasError int out,                                                                                            
    @Message varchar(max) out,
	@IdElasticCustomer varchar(max) output, /*Optimizacion Agente*/
	@IdCustomerOut int output /*Optimizacion Agente*/
)
as
Begin Try  
declare @IdStatus int 
declare @IdAgentPaymentSchema int 
declare @HasErrorBit bit
declare @Login nvarchar(max) = ''
declare @CountryCode nvarchar(max)
declare @IdProvider int = 2 --transferto
declare @IdAgentBalanceService int = 4 --topup
declare @TransactionDate datetime
declare
    @IdTransactionTTo int = 0,
    @OperatorReference nvarchar(max) = '',
    @LocalInfoAmount money = 0,
    @LocalInfoCurrency nvarchar(max) = '',
    @LocalInfoValue money = 0,
    @ReturnTimeStamp datetime = '01/01/1900',    
    @Response nvarchar(max) = '',     
    @pinBased bit = 0,
    @pinValidity nvarchar(max) = '',
    @pinCode nvarchar(max) = '',
    @pinIvr nvarchar(max) = '',
    @pinSerial nvarchar(max) = '',
    @pinValue nvarchar(max) = '',
    @pinOption1 nvarchar(max) = '',
    @pinOption2 nvarchar(max)= '',
    @pinOption3 nvarchar(max)

    --fix temporal zona horaria
    --set @ReturnTimeStamp = dateadd(HOUR, -5, @ReturnTimeStamp) 
    
    set @IdStatus=1 --Paid   
    /*
    if exists (select top 1 1 from TransferTo.[TransferTTo] where IdTransactionTTo=@IdTransactionTTo) 
    begin
        Set @HasError=2                                                                                    
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE61')
        return
    end
    */

   if (isnull(@IdCustomer,0)=0 and (ltrim(rtrim(isnull(@Msisdn,'')))!='' or (ltrim(rtrim(isnull(@Name,'')))!='' and ltrim(rtrim(isnull(@FirstLastName,'')))!='' and ltrim(rtrim(isnull(@SecondLastName,'')))!='') ))
   begin
   exec [TransferTo].[st_CreateCustomer]
		@Msisdn,
		@IdAgent,
		@EnterByIdUser, 
		@Name,
		@FirstLastName,
		@SecondLastName, 
		@IdCustomer OUTPUT,
		@HasErrorBit OUTPUT,
		@IdElasticCustomer OUTPUT /*Optimizacion Agente*/

		set @IdCustomerOut = @IdCustomer /*Optimizacion Agente*/
        if @HasErrorBit=1 
        begin
            Set @HasError=3                                                                                   
            SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
            return
        end

    end
	else
	begin
		set @IdCustomerOut = @IdCustomer /*Optimizacion Agente*/
	end


    declare @IdCustomerFrequentNumberout int

    if (@SaveCustomerFrequentNumber=1 and isnull(@IdCustomer,0)>0)
    begin 
        
        exec [TransFerTo].[st_SaveCustomerFrequentNumber]
		@IdCustomerFrequentNumber,
		@IdCustomer,
		@NickName ,		
		@Destination_Msisdn,
		@EnterByIdUser,
		@IdCustomerFrequentNumberout OUTPUT,
		@HasErrorBit OUTPUT

        set @IdCustomerFrequentNumber = @IdCustomerFrequentNumberout

        if @HasErrorBit=1 
        begin
            Set @HasError=3                                                                                   
            SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
            return
        end
                        
    end

    select @CountryCode=CountryCode from TransferTo.Country where countryname=@Country
    
    set @Country=upper(@Country)

    set @CountryCode= isnull(@CountryCode,@Country)

    set @TransactionDate = getdate()

    --calculos balance
             select @IdAgentPaymentSchema=IdAgentPaymentSchema from agent where idagent=@IdAgent
             declare @TotalAmountToCorporate money = 0

             if (@IdAgentPaymentSchema=2)
                set @TotalAmountToCorporate = @WholeSalePrice+@CorpCommission
            else
                set @TotalAmountToCorporate = @RetailPrice

    EXEC	[Operation].[st_CreateProductTransfer]
		@IdProvider = @IdProvider,
		@IdAgentBalanceService = @IdAgentBalanceService,
		@IdOtherProduct = @IdOtherProduct,
		@IdAgent = @IdAgent,
		@IdAgentPaymentSchema = @IdAgentPaymentSchema,
		@TotalAmountToCorporate = @TotalAmountToCorporate,
		@Amount = @RetailPrice,
		@Commission = @Commission,
        @fee = 0,
        @TransactionFee = 0,
		@AgentCommission = @AgentCommission,
		@CorpCommission = @CorpCommission,
		@EnterByIdUser = @EnterByIdUser,
		@TransactionDate = @TransactionDate,
		@TransactionID = @IdTransactionTTo,
		@HasError = @HasError OUTPUT,
		@IdProductTransferOut = @IdProductTransferOut OUTPUT

    if   @HasError=0             
    begin

        set @IdStatus = 21

        insert into  TransferTo.[TransferTTo](	
                IdAgent,
                [Action],
                [Key],
                Msisdn,
                Destination_Msisdn,
                Product,
                Operator,
                OriginCurrency,
                DestinationCurrency,
                WholeSalePrice,
                RetailPrice,            
                IdTransactionTTo,
                Country,
                OperatorReference,
                LocalInfoAmount,
                LocalInfoCurrency,
                LocalInfoValue,
                ReturnTimeStamp,        
                Commission,
                --CommissionPercent,
                AgentCommission,
                CorpCommission,
                [IdStatus],
                DateOfCreation,
                IdOtherProduct,
                login,
                IdSchema,
                EnterByIdUser,
                IdCustomer,
                IdCustomerFrequentNumber,
                NickName,
                Response,
                Request,
                pinBased,
                pinValidity,
                pinCode,
                pinIvr,
                pinSerial,
                pinValue,
                pinOption1,
                pinOption2,
                pinOption3,
                IdProductTransfer
            )
            values
            (
                @IdAgent,
                @Action,
                @Key,
                @Msisdn,
                @Destination_Msisdn,
                @Product,
                @Operator,
                @OriginCurrency,
                @DestinationCurrency,
                @WholeSalePrice,
                @RetailPrice,            
                @IdTransactionTTo,
                @Country,
                @OperatorReference,
                @LocalInfoAmount,
                @LocalInfoCurrency,
                @LocalInfoValue,
                @ReturnTimeStamp,
                @Commission,
                --@CommissionPercent,
                @AgentCommission,
                @CorpCommission,
                @IdStatus,
                getdate(),
                @IdOtherProduct,
                @Login,
                @IdSchema,
                @EnterByIdUser,
                @IdCustomer,
                @IdCustomerFrequentNumber,
                @NickName,
                @Response,
                @Request,
                @pinBased,
                @pinValidity,
                @pinCode,
                @pinIvr,
                @pinSerial,
                @pinValue,
                @pinOption1,
                @pinOption2,
                @pinOption3,
                @IdProductTransferOut
            )             

             --Afectar Balance         

             EXEC	[dbo].[st_OtherProductToAgentBalance]
		        @IdTransaction = @IdProductTransferOut,
		        @IdOtherProduct = @IdOtherProduct,
		        @IdAgent = @IdAgent,
		        @IsDebit = 1,
		        @Amount = @TotalAmountToCorporate,
		        @Description = @Destination_Msisdn,
		        @Country = @Operator,
		        @Commission = @Commission,
		        @AgentCommission = @AgentCommission,
		        @CorpCommission = @CorpCommission,
		        @FxFee = 0,
		        @Fee = 0,
		        @ProviderFee = 0

            exec [Operation].[st_SaveChangesToProductTransferLog]
		        @IdProductTransfer = @IdProductTransferOut,
		        @IdStatus = 1,
		        @Note = 'Transfer Charge Added to Agent Balance',
		        @IdUser = 0,
		        @CreateNote = 0


             set @IdStatus = 21
             
             EXEC	[Operation].[st_UpdateProductTransferStatus]
		        @IdProductTransfer = @IdProductTransferOut,
		        @IdStatus = @IdStatus,
		        @TransactionDate = @TransactionDate,
		        @HasError = @HasError OUTPUT 

             Set @HasError=1
             SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')
    end
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=3                                                                                   
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_CreateTransferTTo',Getdate(),@ErrorMessage)                                                                                            
End Catch  

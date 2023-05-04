CREATE procedure [dbo].[st_CreatePureMinutesTransaction]
(
    @IdProductTransfer bigint,
	@IdUser int ,
	@IdAgent int ,
    @IsSpanishLanguage int,    
    @ReceiveAccountNumber nvarchar(max) ,
    @IdCustomer int,
    @SenderName nvarchar(max) ,
    @SenderFirstLastName nvarchar(max) ,
    @SenderSecondLastName nvarchar(max) ,
    @SenderAddress nvarchar(max) ,
    @SenderCity nvarchar(max) ,
    @SenderState nvarchar(max) ,    
    @SenderZipCode nvarchar(max) ,
	@SenderPhoneNumber nvarchar(max),
    @PromoCode nvarchar(max) ,
    @ReceiveAmount money ,
	@Fee money ,	
	@AgentCommission money ,
	@CorpCommission money ,    
    @Status int ,
    @AgentReferenceNumber nvarchar(max),
    @ReturnCode nvarchar(max),    
    @Request nvarchar(max) ,
    @Response nvarchar(max) , 
    @PromocodeResponse nvarchar(max),   
    @PureMinutesTransID nvarchar(max),
    @PureMinutesUserID nvarchar(max),
    @ConfirmationCode nvarchar(max),
    @ActualReceiveDateTime datetime,    
    @Balance money,
    @CreditForPromoCode money,    
    @IdCustomerOut int out,
    @Bonification BIT,
	@AccessNumber nvarchar(max),
    @HasError int out,
    @Message nvarchar(max) out,
    @Idtransfer int = null,
    @IsSaveCustomer bit = null,
    @IdProductTransferOUT bigint out
)
as
begin try   
    declare @IdPureMinutesOut int
    declare @IdProvider int = 4 --PureMinutes
    declare @IdAgentBalanceService int = 3 --LongDistance 
    declare @IdOtherProduct int = 5 
    declare @IdAgentPaymentSchema int
    declare @TotalAmountToCorporate money    
    
    set @HasError=0
    SET @IdCustomerOut=0
    Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,6)    

    if(@IdCustomer=0 AND LTRIM(RTRIM(upper(@SenderName+ ' '+@SenderFirstLastName+' '+@SenderSecondLastName)))!='MAXI TRANSFERS' )
    begin
        insert into customer 
        (
            Name,
            FirstLastName,
            SecondLastName,
            CelullarNumber,
            Country,
            State,
            City,
            DateOfLastChange,            
            EnterByIdUser,
            ExpirationIdentification,
            IdAgentCreatedBy,
            IdGenericStatus,
            IdCustomerIdentificationType,
            IdentificationNumber,
            Occupation,
            PhoneNumber,
            PhysicalIdCopy,
            SSNumber,
            Zipcode,
            Address,
			[creationdate]
        )
        values
        (
            @SenderName,
            @SenderFirstLastName,
            @SenderSecondLastName,
            @SenderPhoneNumber,
            'USA',
            @SenderState,
            @SenderCity,
            getdate(),
            @IdUser,
            null,
            @IdAgent,
            1,
            null,
            '',
            '',
            '',
             0,
            '',
            @SenderZipCode,
            @SenderAddress,
			GETDATE()
        )

        set @IdCustomerOut = SCOPE_IDENTITY()

    end
    else
    begin
        
        if (@IsSaveCustomer=1)  
        begin
        exec st_SaveCustomerMirror @IdCustomer 

        Update Customer 
            set 
                --Name=@SenderName,
                --FirstLastName=@SenderFirstLastName,
                --SecondLastName = @SenderSecondLastName,
                --City = @SenderCity,
                --State = @SenderState,
                --Address = @SenderAddress,
                --Zipcode = isnull(@SenderZipCode,Zipcode),
                 CelullarNumber = isnull(case (@SenderPhoneNumber) when '' then null else @SenderPhoneNumber end,CelullarNumber)
                ,Enterbyiduser=@IdUser
                ,dateoflastchange=getdate()
        where IdCustomer=@IdCustomer        
        end
        set @IdCustomerOut = @IdCustomer
    end

    select @IdAgentPaymentSchema=IdAgentPaymentSchema from agent with (nolock) where idagent=@IdAgent

    --calculos balance
if (@IdAgentPaymentSchema=2)
    set @TotalAmountToCorporate = @ReceiveAmount-@AgentCommission
else
    set @TotalAmountToCorporate = @ReceiveAmount

    if (@IdProductTransfer=0)
    begin

        EXEC	[Operation].[st_CreateProductTransfer]
		@IdProvider = @IdProvider,
		@IdAgentBalanceService = @IdAgentBalanceService,
		@IdOtherProduct = @IdOtherProduct,
		@IdAgent = @IdAgent,
		@IdAgentPaymentSchema = @IdAgentPaymentSchema,
		@TotalAmountToCorporate = @TotalAmountToCorporate,
		@Amount = @ReceiveAmount,
		@Commission = 0,
        @fee = @fee,
        @TransactionFee =0,
		@AgentCommission = @AgentCommission,
		@CorpCommission = @CorpCommission,
		@EnterByIdUser = @IdUser,
		@TransactionDate = @ActualReceiveDateTime,
		@TransactionID = @PureMinutesTransID,
		@HasError = @HasError OUTPUT,
		@IdProductTransferOut = @IdProductTransferOUT OUTPUT        

        insert into PureMinutesTransaction
        (            
	        IdUser,
	        IdAgent,
            DateOfTransaction,
	        DateOfLastChange,
            ReceiveAccountNumber,
            IdCustomer,
            SenderName,
            SenderFirstLastName,
            SenderSecondLastName,
            SenderAddress,
            SenderCity,
            SenderState,
            SenderCountry,
            SenderZipCode,
			SenderPhoneNumber,
            PromoCode,
            ReceiveAmount,
	        Fee,
	        AgentCommission,
	        CorpCommission,
            Status,
            LastReturnCode,
            Request,
            Response,
            AgentReferenceNumber,
            Bonification,
			AccessNumber,
            Idtransfer ,
            IdProductTransfer           
        )
        values
        (
            @IdUser,
	        @IdAgent,
            getdate(),
	        getdate(),
            @ReceiveAccountNumber,
            @IdCustomerOut,
            @SenderName,
            @SenderFirstLastName,
            @SenderSecondLastName,
            @SenderAddress,
            @SenderCity,
            @SenderState,
            'USA',
            @SenderZipCode,
			@SenderPhoneNumber,
            @PromoCode,
            @ReceiveAmount,
	        @Fee,
	        @AgentCommission,
	        @CorpCommission,
            @Status,
            @ReturnCode,
            @Request,
            @Response,
            @AgentReferenceNumber,
            @Bonification,
			@AccessNumber,
            @Idtransfer ,
            @IdProductTransferOUT           
        )

        set @IdPureMinutesOut = SCOPE_IDENTITY()

        insert into PureMinutesResponseLog
        (IdPureMinutes,Date,Status,ReturnCode,Request,Response)
        values
        (@IdPureMinutesOut,getdate(),@Status,@ReturnCode,@Request,@Response)

    end
    else
    begin
        update PureMinutesTransaction set
            DateOfLastChange=getdate(),	        
            ReceiveAccountNumber=isnull(@ReceiveAccountNumber,ReceiveAccountNumber),
            IdCustomer = isnull(@IdCustomer,IdCustomer),
            SenderName=isnull(@SenderName,SenderName),
            SenderFirstLastName=isnull(@SenderFirstLastName,SenderFirstLastName),
            SenderSecondLastName=isnull(@SenderSecondLastName,SenderSecondLastName),
            SenderAddress=isnull(@SenderAddress,SenderAddress),
            SenderCity=isnull(@SenderCity,SenderCity),
            SenderState=isnull(@SenderState,SenderState),
            --SenderCountry=isnull(@SenderCountry,SenderCountry),
			SenderPhoneNumber = isnull(@SenderPhoneNumber,SenderPhoneNumber),
            SenderZipCode=isnull(@SenderZipCode,SenderZipCode),
            PromoCode=isnull(@PromoCode,PromoCode),
            ReceiveAmount=isnull(@ReceiveAmount,ReceiveAmount),
	        Fee=isnull(@Fee,Fee),
	        AgentCommission=isnull(@AgentCommission,AgentCommission),
	        CorpCommission=isnull(@CorpCommission,CorpCommission),
            Status=@Status,
            LastReturnCode=@ReturnCode,
            Request=@Request,
            Response=@Response,
            PureMinutesTransID=@PureMinutesTransID,
            PureMinutesUserID=@PureMinutesUserID,
            ConfirmationCode=@ConfirmationCode,
            ActualReceiveDateTime=@ActualReceiveDateTime,    
            Balance=@Balance,
            AgentReferenceNumber=isnull(@AgentReferenceNumber,AgentReferenceNumber),
            PromocodeResponse = @PromocodeResponse,
            CreditForPromoCode = @CreditForPromoCode,
            Bonification = @Bonification,
			AccessNumber = @AccessNumber,
            Idtransfer = isnull(@Idtransfer,Idtransfer),
            @IdPureMinutesOut = Idpureminutes
        where IdProductTransfer=@IdProductTransfer

        update operation.producttransfer 
            set TransactionProviderID=@PureMinutesTransID,
                TotalAmountToCorporate = isnull(@TotalAmountToCorporate,TotalAmountToCorporate),
		        Amount = isnull(@ReceiveAmount,Amount),		        
                fee = isnull(@fee,fee),                
		        AgentCommission = isnull(@AgentCommission,AgentCommission),
		        CorpCommission = isnull(@CorpCommission,CorpCommission),
		        EnterByIdUser = isnull(@IdUser,EnterByIdUser),
		        TransactionProviderDate = isnull(@ActualReceiveDateTime,TransactionProviderDate)
        where IdProductTransfer=@IdProductTransfer

        set @IdProductTransferOut=@IdProductTransfer

        insert into PureMinutesResponseLog
        (IdPureMinutes,Date,Status,ReturnCode,Request,Response)
        values
        (@IdPureMinutesOut,getdate(),@Status,@ReturnCode,@Request,@Response)

    end

    declare @IdStatus int

    set @IdStatus = case when @Status = 1 then 30 when @Status=2 then 22 end

    if @IdStatus in (22,30)
    begin
    EXEC	[Operation].[st_UpdateProductTransferStatus]
		        @IdProductTransfer = @IdProductTransferOUT,
		        @IdStatus = @IdStatus,
		        @TransactionDate = @ActualReceiveDateTime,
                @EnterByIdUser = @IdUser,
		        @HasError = @HasError OUTPUT      
    end

end try
begin catch
    Set @HasError=1                                                                                   
    Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,7)                                                                               
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CreatePureMinutesTransaction',Getdate(),@ErrorMessage)
end catch

CREATE procedure [dbo].[st_CreatePureMinutesTopUpTransaction]
(
    @IdPureMinutesTopUp int  ,
    --@IsSpanishLanguage int ,
    @IdLenguage int,
	@IdUser int ,
	@IdAgent int ,
	@DateOfTransaction datetime ,
	@DateOfLastChange datetime ,

    @IdBiller INT,
    @BillerIDTopUp int ,	
    @CarrierID int ,	
    @CountryID int ,
    @TopUpNumber nvarchar(max) ,	
	@BuyerPhonenumber nvarchar(max) ,	
	@TopUpAmount money ,
        
    @PureMinutesTopUpTransID nvarchar(max) ,	
    @EntryTimeStamp nvarchar(max),	    
    @ReturnCode nvarchar(max) ,	
    @ReasonCode nvarchar(max) ,	
    @ReceiverCurrency nvarchar(max) ,	    
    @RechargeCurrency nvarchar(max) , 
    @ReceiverAmount nvarchar(max) ,	
    @RechargeAmount nvarchar(max) ,	    

	@Fee money ,
	@AgentCommission money ,
	@CorpCommission money ,    
	@Status int ,
	@LastReturnCode nvarchar(max) ,
	@Request nvarchar(max) ,
	@Response nvarchar(max) ,
    @ErrorMessageTP nvarchar(max) ,
	@ResponseErrorMessage nvarchar(max) ,

    @IdPureMinutesTopUpOut int out,    
    @HasError int out,
    @Message nvarchar(max) out
)
as

if @IdLenguage is null 
    set @IdLenguage=2

begin try    
    set @HasError=0
    --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,6)    
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')

    if (@IdPureMinutesTopUp=0)
    begin
        insert into PureMinutesTopUpTransaction
        (                
	        IdUser  ,
	        IdAgent  ,
	        DateOfTransaction  ,
	        DateOfLastChange  ,
            BillerID  ,	
            CarrierID  ,	
            TopUpNumber  ,	
	        BuyerPhonenumber  ,	
	        TopUpAmount  ,        
            PureMinutesTopUpTransID  ,	
            EntryTimeStamp ,	    
            ReturnCode  ,	
            ReasonCode  ,	
            ReceiverCurrency  ,	    
            RechargeCurrency  , 
            CountryID  , 
	        Fee  ,
	        AgentCommission  ,
	        CorpCommission  ,
	        Status  ,	        
	        LastReturnCode  ,
	        Request  ,
	        Response,
            ReceiverAmount,	
            RechargeAmount,
            IdBiller            
        )
        values
        (
            @IdUser,
            @IdAgent,
            getdate(),
            getdate(),
            @BillerIDTopUp,
            @CarrierID,
            @TopUpNumber,
            @BuyerPhonenumber,
            @TopUpAmount,
            @PureMinutesTopUpTransID,
            @EntryTimeStamp,
            @ReturnCode,
            @ReasonCode,
            @ReceiverCurrency,
            @RechargeCurrency,
            @CountryID,
            @Fee,
            @AgentCommission,
            @CorpCommission,
            @Status,            
            @LastReturnCode,
            @Request,
            @Response,
            @ReceiverAmount,	
            @RechargeAmount,
            @IdBiller            
        )

        set @IdPureMinutesTopUpOut = SCOPE_IDENTITY()

        insert into [MAXILOG].[dbo].PureMinutesTopUpResponseLog
        (IdPureMinutesTopUp,Date,Status,ReturnCode,Request,Response)
        values
        (@IdPureMinutesTopUpOut,getdate(),@Status,@ReturnCode,@Request,@Response)

    end
    else
    begin
            update PureMinutesTopUpTransaction set	        
	        DateOfLastChange  = GETDATE(),        
            PureMinutesTopUpTransID  = @PureMinutesTopUpTransID,	
            EntryTimeStamp = @EntryTimeStamp,	    
            ReturnCode  = @ReturnCode,	
            ReasonCode  = @ReasonCode,	
            ReceiverCurrency  = @ReceiverCurrency,	    
            RechargeCurrency  = @RechargeCurrency, 
            ReceiverAmount = @ReceiverAmount,	
            RechargeAmount = @RechargeAmount,
	        Status  = @Status,	        
	        LastReturnCode  = @ReturnCode,
	        Request  = @Request,
	        Response = @Response,
            ErrorMsg = @ErrorMessageTP,
	        ResponseMsg = @ResponseErrorMessage
        where IdPureMinutesTopUp=@IdPureMinutesTopUp

        set @IdPureMinutesTopUpOut=@IdPureMinutesTopUp

        insert into [MAXILOG].[dbo].PureMinutesTopUpResponseLog
        (IdPureMinutesTopUp,Date,Status,ReturnCode,Request,Response)
        values
        (@IdPureMinutesTopUpOut,getdate(),@Status,@ReturnCode,@Request,@Response)

    end
end try
begin catch
    Set @HasError=1                                                                                   
    --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,7)                                                                               
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CreatePureMinutesTopUpTransaction',Getdate(),@ErrorMessage)
end catch

CREATE PROCEDURE [ExRateService].[st_SaveExRateSchedule]
(
	@AskedToUser bit,
    @IdExRateSchedule int,
	@IdCountryCurrency int,
    @IdGateway int = null,
	@IdPayer int  = null,
	@ExRate money,	
    @ScheduleDate datetime,	
	@EnterByIdUser int,
    @IdLenguage int,    
    @IdExRateScheduleOut int out,
    @HasError bit out,  
    @MessageOut nvarchar(max) out,
	@ShowWarning bit out
)
as
begin try

declare @currentExchangeRate money
declare @percentageAllowed money

if @IdLenguage is null 
    set @IdLenguage=2
	set @ShowWarning =0
	
	--*****************  validating if new exchange rate is out of allowed values ***************
	if (@AskedToUser=0)
	begin
		 select @percentageAllowed = Cast(Value as money) from GlobalAttributes where Name='AllowedPercentageRefExRate'		 
		 select top 1 @currentExchangeRate=RefExRate from RefExRate where IdCountryCurrency = @IdCountryCurrency and IdGateway = isnull(@IdGateway,IdGateway)
		 and IdPayer = isnull(@IdPayer,IdPayer) and Active =1 order by DateOfLastChange desc
		 if (@currentExchangeRate * (1+(@percentageAllowed/100)) < @ExRate)
		 begin
			set @ShowWarning = 1
			set @HasError =1
			set @IdExRateScheduleOut =0
			SELECT @MessageOut=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'EXRATE2')
			return
		 end		 
	end

    if (isnull(@IdExRateSchedule,0)=0)
    begin
        INSERT INTO ExRateService.[ExRateSchedule]
               ([IdCountryCurrency]
               ,[IdGateway]
               ,[IdPayer]
               ,[ExRate]
               ,[ScheduleDate]
               ,[EnterByIdUser]
               ,[DateOfLastChange]
               ,[ServiceApplyDate]
               ,[IsApply]
               ,[IdGenericStatus])
         VALUES
               (@IdCountryCurrency
               ,@IdGateway
               ,@IdPayer
               ,@ExRate
               ,@ScheduleDate
               ,@EnterByIdUser
               ,getdate()
               ,null
               ,0
               ,1)

        set @IdExRateScheduleOut = SCOPE_IDENTITY()
    end
    else
    begin
    UPDATE ExRateService.[ExRateSchedule]
       SET [IdCountryCurrency] = @IdCountryCurrency
          ,[IdGateway] = @IdGateway
          ,[IdPayer] = @IdPayer
          ,[ExRate] = @ExRate
          ,[ScheduleDate] = @ScheduleDate
          ,[EnterByIdUser] = @EnterByIdUser
          ,[DateOfLastChange] = getdate()                  
     WHERE IdExRateSchedule=@IdExRateSchedule

        set @IdExRateScheduleOut=@IdExRateSchedule
    end

    set @HasError =0    
    SELECT @MessageOut=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'EXRATE0')	

end try
Begin Catch  
   Declare @ErrorMessage nvarchar(max)           
   Select @ErrorMessage=ERROR_MESSAGE()          
   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('ExRateService.st_SaveExRateSchedule',Getdate(),@ErrorMessage)   
   set @HasError =1    
   SELECT @MessageOut=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'EXRATE1')
End catch 

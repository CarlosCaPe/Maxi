CREATE PROCEDURE [Corp].[st_SaveExRateSchedule_ExRateService]
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
		 select @percentageAllowed = Cast(Value as money) from GlobalAttributes WITH (NOLOCK) where Name='AllowedPercentageRefExRate' 
		 		 
		 select top 1 @currentExchangeRate = RefExRate 
		 from RefExRate WITH (NOLOCK) 
		 where IdCountryCurrency = @IdCountryCurrency
		 	AND isnull(IdGateway, 0) = isnull(@IdGateway,0)
		 	AND isnull(IdPayer, 0) = isnull(@IdPayer, 0)
		 	and Active =1 
		 order by DateOfLastChange DESC	
		 
		 
		 
		 
		 IF (isnull(@currentExchangeRate, 0) > 0)
		 BEGIN
		 	--SELECT '1'
			 if (@currentExchangeRate * (1+(@percentageAllowed/100)) < @ExRate)
			 BEGIN
			 	
				set @ShowWarning = 1
				set @HasError =1
				set @IdExRateScheduleOut =0
				DECLARE @limitAount DECIMAL(18,4) = (@currentExchangeRate * (1+(@percentageAllowed/100)))
				SELECT @MessageOut=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'EXRATE2') + ' Max value allowed is ' + FORMAT(@limitAount, '$###.##')
				return
			 END		 
		 
		 END
		 
--		 SELECT @currentExchangeRate AS 'Current', (@currentExchangeRate * (1+(@percentageAllowed/100))) AS 'Limit', @ExRate AS 'New'
--		 RETURN
		 
		 
		 
		 --RETURN		 
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


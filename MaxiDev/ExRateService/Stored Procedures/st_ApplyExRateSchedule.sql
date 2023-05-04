CREATE procedure [ExRateService].[st_ApplyExRateSchedule]
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
as
begin try

declare @BeginDate datetime,
        @EndDate datetime,
        @MinutesService int
Declare @schedule TABLE
        (
            IdExRateSchedule int,
            IdCountryCurrency int,
            IdGateway int,
            IdPayer int,
            ExRate money,
            ScheduleDate datetime
        )

 Declare
    @IdExRateSchedule int,
    @IdCountryCurrency int,
    @IdGateway int,
	@IdPayer int,
	@ExRate money,
    @ScheduleDate datetime,
    @ApplyDate datetime,
    @EnterByIdUser int,
    @Message nvarchar(max)

set @EndDate=getdate()
Set @MinutesService=dbo.GetGlobalAttributeByName('ExRateProgrammedTick')
set @EnterByIdUser=dbo.GetGlobalAttributeByName('SystemUserID')
set @BeginDate=DATEADD(minute,(-1)*@MinutesService, @EndDate);

--select @BeginDate,@EndDate

insert into @schedule
select IdExRateSchedule,IdCountryCurrency,IdGateway,IdPayer,ExRate,ScheduleDate from ExRateService.ExRateSchedule WITH(NOLOCK)
where isapply=0 and idgenericstatus=1
and ScheduleDate>=@BeginDate and ScheduleDate<=@EndDate

--select * from @schedule

--Informacion de tipo de cambio obtenida

select @Message = 'Total Exchange Rate To Apply : '+ convert(varchar,count(1))+'' from @schedule

INSERT INTO [ExRateService].[ServiceLogDetails]
           ([Category]
           ,[Message]
           ,[IdExRateSchedule]
           ,[ServiceApplyDate]
           ,[DateLog])
     VALUES
           ('Get Information'
           ,@Message
           ,null
           ,null
           ,getdate())


while(Exists(Select IdExRateSchedule from @schedule))
begin
    select 
        top 1 
            @IdExRateSchedule=IdExRateSchedule,
            @IdCountryCurrency = IdCountryCurrency,
            @IdGateway = IdGateway,
	        @IdPayer = IdPayer,
	        @ExRate = ExRate,
            @ScheduleDate = ScheduleDate
    from 
        @schedule
    order by ScheduleDate


        set @ApplyDate = getdate()        
        
        EXECUTE [dbo].[st_SaveRefExRate] 
		     @IdCountryCurrency
		    ,@ExRate
		    ,@ApplyDate
		    ,@EnterByIdUser
		    ,@IdGateway
		    ,@IdPayer   

       UPDATE ExRateService.[ExRateSchedule]
       SET 
            [ServiceApplyDate] = getdate()
           ,[IsApply]        = 1
       WHERE IdExRateSchedule=@IdExRateSchedule


       select @Message = 'Apply Exrate Schedule ID : '+ convert(varchar,@IdExRateSchedule)+'' from @schedule

       INSERT INTO [ExRateService].[ServiceLogDetails]
           ([Category]
           ,[Message]
           ,[IdExRateSchedule]
           ,[ServiceApplyDate]
           ,[DateLog])
        VALUES
           ('Apply Exrate'
           ,@Message
           ,@IdExRateSchedule
           ,@ApplyDate
           ,getdate())        

    delete from @schedule where IdExRateSchedule=@IdExRateSchedule
end

--select * from @schedule

end try
Begin Catch  
   Declare @ErrorMessage nvarchar(max)           
   Select @ErrorMessage=ERROR_MESSAGE()          
   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('ExRateService.st_ApplyExRateSchedule',Getdate(),@ErrorMessage)      
End catch 
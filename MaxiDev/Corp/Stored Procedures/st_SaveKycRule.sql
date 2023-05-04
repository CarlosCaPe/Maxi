CREATE PROCEDURE [Corp].[st_SaveKycRule]
@IdRule int out,
@RuleName nvarchar(max),
@IdPayer int,
@IdPaymentType int,
@IdAgent int,
@IdCountry int,
@IdGateway int,
@Actor nvarchar(max),
@Symbol nvarchar(max),
@Amount money,
@AgentAmount bit,
@IdCountryCurrency int,
@TimeInDays int,
@Action int,
@MessageInSpanish nvarchar(max),
@MessageInEnglish nvarchar(max),
@IdGenericStatus int,
@EnterByIdUser int,
@Factor decimal,
@IsSpanishLanguage bit,          
@SSNRequired bit,
@OccupationRequired bit,
@IsConsecutive bit, --New RMM
@Transfer int, --New RMM
@IsExpire bit = null,
@ExpirationDate datetime =null,
@ComplianceFormatId INT = NULL, -- Compliance Format

/*>> s35*/
 @IdTypeRequired BIT
,@IdNumberRequired BIT
,@IdExpirationDateRequired BIT 
,@IdStateCountryRequired BIT
,@DateOfBirthRequired BIT
/*<< s35*/

,@HasError bit out,          
@Message varchar(max) out, 
@IdState int = null
,@IdStateDestination int = null /*S28*/
as    

/********************************************************************
<Author>Not Known</Author>
<app>MaxiRefactoryCorp</app>
<Description></Description>

<ChangeLog>
<log Date="17/02/2017" Author="jmoreno">Se agrega el IdState para el guardado de la KYC</log>
<log Date="29/06/2017" Author="snevarez">Se agrega el IdStateDestination para el guardado de la KYC y usarlo en la aplicacion de reglas por estado destino</log>
<log Date="16/08/2017" Author="mdelgado">Add columns requiereds Sem35</log>
<log Date="03/01/2020" Author="jzuniga">Se especifican campos de la tabla</log>
</ChangeLog>
********************************************************************/

Declare @dataxml xml
Declare @TaskLog nvarchar(max)
--Declare @OLDIdGenericStatus int = @IdGenericStatus
declare @MessageMail nvarchar(max)
declare @Body nvarchar(max)
declare @UserName nvarchar(max)

set @IsExpire = ISNULL(@IsExpire,0)
select @UserName=username from users with(nolock) where IdUser=@EnterByIdUser

IF @ComplianceFormatId <= 0 SET @ComplianceFormatId = NULL

Begin Try  

	If(@Actor='Customer' or @Actor='Beneficiary' or @Actor='NewCustomer')
		Begin
			If(@AgentAmount=1)
				Begin
					set @Amount =null 
					set @IdCountryCurrency= Convert(int,(select value from dbo.GlobalAttributes with(nolock) where Name='IdCountryCurrencyDollars'))
				End
			set @Factor = null
		End
	If(@Actor='NewCustomer')
		Begin
			set @TimeInDays = null
			set @Factor = null
		End
	If(@Actor='InactiveCustomer')
		Begin
			set @AgentAmount = 0
			set @Symbol='>'
			set @Factor = null
		End
	If(@Actor='AverageCustomer')
		Begin
			set @AgentAmount = 0
			set @Symbol='>'
			set @TimeInDays = null
			set @IdCountryCurrency= Convert(int,(select value from dbo.GlobalAttributes with(nolock) where Name='IdCountryCurrencyDollars'))
		End
	If(@Actor='CountyIdentification')
		Begin
			set @AgentAmount = 0
			set @Symbol='>'
			set @TimeInDays = null
			set @Factor = null
		End
	if (@IdState=0)
	 begin 
	  set  @IdState=null
	 end	

	 /*S28*/
	 if (@IdStateDestination=0)
	 begin 
	  set  @IdStateDestination=null
	 end

  if(@IdRule =0)
	BEGIN
		
	
		INSERT INTO [dbo].[KYCRule]
			([RuleName]
			,[IdPayer]
			,[IdPaymentType]
			,[IdAgent]
			,[IdCountry]
			,[IdGateway]
			,[Actor]
			,[Symbol]
			,[Amount]
			,[AgentAmount]
			,[IdCountryCurrency]
			,[TimeInDays]
			,[Action]
			,[MessageInSpanish]
			,[MessageInEnglish]
			,[IdGenericStatus]
			,[DateOfLastChange]
			,[EnterByIdUser]
			,[Factor]
			,[SSNRequired]
			,[OccupationRequired]
			,Creationdate
			,IsExpire
			,ExpirationDate
			,[IsConsecutive] --New RMM
			,[Transactions] --New RMM
			,[ComplianceFormatId]
			,[IdState] 
			,[IdStateDestination] /*S28*/
			,[IdTypeRequired]
			,[IdNumberRequired]
			,[IdExpirationDateRequired]
			,[IdStateCountryRequired]
			,[DateOfBirthRequired]
		   )
     VALUES
           (
			 @RuleName 
			,@IdPayer 
			,@IdPaymentType
			,@IdAgent
			,@IdCountry
			,@IdGateway
			,@Actor 
			,@Symbol
			,@Amount
			,@AgentAmount
			,@IdCountryCurrency
			,@TimeInDays
			,@Action
			,@MessageInSpanish
			,@MessageInEnglish
			,@IdGenericStatus
			,GETDATE()
			,@EnterByIdUser
			,@Factor
			,@SSNRequired
			,@OccupationRequired
			,getdate()
			,@IsExpire
			,@ExpirationDate
			,@IsConsecutive --New RMM
			,@Transfer  --New RMM
			,@ComplianceFormatId
			,@IdState
			,@IdStateDestination /*S28*/
			/*>> S35 */
			,@IdTypeRequired
			,@IdNumberRequired
			,@IdExpirationDateRequired
			,@IdStateCountryRequired
			,@DateOfBirthRequired
			/*<< S35 */
		   )

		set @IdRule = SCOPE_IDENTITY()

        set @TaskLog = 'INSERT'
	End
  Else
	Begin
                
        --select @OLDIdGenericStatus=IdGenericStatus from [KYCRule] WHERE IdRule=@IdRule         

		UPDATE [dbo].[KYCRule]
		   SET [RuleName] = @RuleName
				,[IdPayer] = @IdPayer
				,[IdPaymentType] = @IdPaymentType
				,[IdAgent] = @IdAgent
				,[IdCountry] = @IdCountry
				,IdGateway = @IdGateway
				,[Actor] = @Actor
				,[Symbol] = @Symbol
				,[Amount] = @Amount
				,[AgentAmount] = @AgentAmount
				,[IdCountryCurrency] = @IdCountryCurrency
				,[TimeInDays] = @TimeInDays
				,[Action] = @Action
				,[MessageInSpanish] = @MessageInSpanish
				,[MessageInEnglish] = @MessageInEnglish
				,[IdGenericStatus] = @IdGenericStatus
				,[DateOfLastChange] = GETDATE()
				,[EnterByIdUser] = @EnterByIdUser
				,[Factor] = @Factor
				,[SSNRequired] = @SSNRequired
				,[OccupationRequired] = @OccupationRequired
				,[IsConsecutive] = @IsConsecutive --New RMM
				,[Transactions] = @Transfer --New RMM
				,IsExpire=@IsExpire
				,ExpirationDate=@ExpirationDate
				,[ComplianceFormatId]=@ComplianceFormatId
				,[IdState] = @IdState
				,[IdStateDestination] = @IdStateDestination /*S28*/
				/*>> S35*/
				,IdTypeRequired = @IdTypeRequired
				,IdNumberRequired = @IdNumberRequired
				,IdExpirationDateRequired = @IdExpirationDateRequired
				,IdStateCountryRequired = @IdStateCountryRequired
				,DateOfBirthRequired = @DateOfBirthRequired
				/*<< S35*/
		 WHERE IdRule=@IdRule

         set @TaskLog = 'UPDATE'

	End  

    set @dataxml = (
		select
				IdRule,
				RuleName,
				IdPayer,
				IdPaymentType,
				Actor,
				Symbol,
				Amount,
				AgentAmount,
				IdCountryCurrency,
				TimeInDays,
				[Action],
				MessageInSpanish,
				MessageInEnglish,
				IdGenericStatus,
				DateOfLastChange,
				EnterByIdUser,
				IdAgent,
				IdCountry,
				IdGateway,
				Factor,
				SSNRequired,
				IsConsecutive,
				Transactions,
				IsExpire,
				ExpirationDate,
				Creationdate,
				ComplianceFormatId,
				OccupationRequired,
				IdState,
				IdStateDestination,
				IdTypeRequired,
				IdNumberRequired,
				IdExpirationDateRequired,
				IdStateCountryRequired,
				DateOfBirthRequired
			from kycrule with(nolock) where idrule=@IdRule FOR XML RAW)
    
    insert into [GenericTableLog]
    (ObjectName,IdGeneric,Operation,XMLValues,DateOfLastChange,EnterByIdUser)
    values
    ('KYCRule',@IdRule,@TaskLog,@dataxml,GETDATE(),@EnterByIdUser)

    Declare @recipients nvarchar (max)                        
    Declare @EmailProfile nvarchar(max)    

    Select @recipients=Value from GLOBALATTRIBUTES with(nolock) where Name='ListEmailKYC'  
    Select @EmailProfile=Value from GLOBALATTRIBUTES with(nolock) where Name='EmailProfiler' 

    if (@TaskLog='INSERT')
    begin
        set @MessageMail = 'KYC Rule Starts - '+@RuleName
        set @Body ='Created by '+@UserName+isnull(', rule ends '+convert(varchar(10),@ExpirationDate,101),'')
    end
    else
    begin   
        set @MessageMail = 'KYC Rule Update - '+@RuleName
        set @Body ='Updated by '+@UserName+isnull(', rule ends '+convert(varchar(10),@ExpirationDate,101),'')     
        /*
        if (@IdGenericStatus=1) and (@OLDIdGenericStatus=2)
        begin
            set @MessageMail = 'KYC Rule '+@RuleName+' was enabled'
            set @Body ='KYC Rule '+@RuleName+' was enabled by  '+@UserName
        end
        else
        begin
            if (@IdGenericStatus=2) and (@OLDIdGenericStatus=1)
            begin
                set @MessageMail = 'KYC Rule '+@RuleName+' was disabled'
                set @Body ='KYC Rule '+@RuleName+' was disabled by  '+@UserName
            end
            else
            begin
                set @MessageMail = 'KYC Rule '+@RuleName+' Updates'
                set @Body ='Updated  by '+@UserName+', rule ends '+isnull(convert(varchar(10),@ExpirationDate,101),'')
            end
        end*/
    end
			
			--FGONZALEZ 20161117
			DECLARE @ProcID VARCHAR(200)
			SET @ProcID =OBJECT_NAME(@@PROCID)

			EXEC [Corp].[sp_MailQueue] 
			@Source   =  @ProcID,
			@To 	  =  @recipients,      
			@Subject  =  @MessageMail,
			@Body  	  =  @body

			/*
            EXEC msdb.dbo.sp_send_dbmail                          
            @profile_name=@EmailProfile,                                                     
            @recipients = @recipients,                                                          
            @body = @body,                                                           
            @subject = @MessageMail
			*/
  
	Set @HasError=0          
	Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,55)  
	
End Try          
Begin Catch          
 Set @HasError=1          
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,54)          
 Declare @ErrorMessage nvarchar(max)           
 Select @ErrorMessage=ERROR_MESSAGE()          
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SaveKycRule]',Getdate(),@ErrorMessage)          
End Catch

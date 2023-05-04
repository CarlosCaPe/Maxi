CREATE procedure [Corp].[st_KycRuleChangeStatus]
    @IdRule int,
    @IdGenericStatus int,
    @EnterByIdUser int,
    @IsSpanishLanguage bit,          
    @HasError bit out,          
    @Message varchar(max) out
as
SET NOCOUNT ON;
/********************************************************************
<Author></Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="03/01/2020" Author="jzuniga">Se especifican campos de la tabla</log>
</ChangeLog>
********************************************************************/

Begin Try  

Declare @dataxml xml
Declare @TaskLog nvarchar(max)
declare @MessageMail nvarchar(max)
declare @Body nvarchar(max)
declare @UserName nvarchar(max)
declare @RuleName nvarchar(max)

        select @UserName=username from users with(nolock) where IdUser=@EnterByIdUser

        UPDATE [dbo].[KYCRule]
		   SET			  
			   [IdGenericStatus] = @IdGenericStatus
			  ,[DateOfLastChange] = GETDATE()
			  ,[EnterByIdUser] = @EnterByIdUser	
              ,@RuleName = rulename		  
		 WHERE IdRule=@IdRule

         set @TaskLog = 'UPDATE'

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
    
        insert into [MAXILOG].[dbo].[GenericTableLog]
            (ObjectName,IdGeneric,Operation,XMLValues,DateOfLastChange,EnterByIdUser)
        values
        ('KYCRule',@IdRule,@TaskLog,@dataxml,GETDATE(),@EnterByIdUser)

        Declare @recipients nvarchar (max)                        
        Declare @EmailProfile nvarchar(max)    

        Select @recipients=Value from GLOBALATTRIBUTES with(nolock) where Name='ListEmailKYC'  
        Select @EmailProfile=Value from GLOBALATTRIBUTES with(nolock) where Name='EmailProfiler' 

        if (@IdGenericStatus=1) 
        begin
            set @MessageMail = 'KYC Rule was enabled - '+@RuleName
            set @Body ='KYC Rule '+@RuleName+' was enabled by '+@UserName
        end
        else
        begin            
            set @MessageMail = 'KYC Rule was disabled - '+@RuleName
            set @Body ='KYC Rule '+@RuleName+' was disabled by '+@UserName            
        end

        EXEC msdb.dbo.sp_send_dbmail                          
            @profile_name=@EmailProfile,                                                     
            @recipients = @recipients,                                                          
            @body = @body,                                                           
            @subject = @MessageMail

    Set @HasError=0          
	Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,55)  

End Try          
Begin Catch          
 Set @HasError=1          
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,54)          
 Declare @ErrorMessage nvarchar(max)           
 Declare @ErrorLine nvarchar(max)
 Select @ErrorMessage=ERROR_MESSAGE()          
 Select @ErrorLine = CONVERT(VARCHAR(20), ERROR_LINE())
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_KycRuleChangeStatus]',Getdate(), 'Line: ' + @ErrorLine + ', ' + @ErrorMessage)          
End Catch  


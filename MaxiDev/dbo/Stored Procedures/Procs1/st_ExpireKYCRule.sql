CREATE procedure [dbo].[st_ExpireKYCRule]
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
as

declare @id int,@EnterByIdUser int,@RuleName nvarchar(max), @UserName nvarchar(max)
declare @Body nvarchar(max)
declare @MessageMail nvarchar(max)
Declare @recipients nvarchar (max)                        
Declare @EmailProfile nvarchar(max)    
Declare @dataxml xml

    Select @recipients=Value from GLOBALATTRIBUTES WITH(NOLOCK) where Name='ListEmailKYC'  
    Select @EmailProfile=Value from GLOBALATTRIBUTES WITH(NOLOCK) where Name='EmailProfiler' 
    set @EnterByIdUser = dbo.GetGlobalAttributeByName('SystemUserID')
    select @UserName=username from users WITH(NOLOCK) where IdUser=@EnterByIdUser

select IdRule,EnterByIdUser,RuleName into #tmpRule from KYCRule WITH(NOLOCK) where IdGenericStatus=1 and IsExpire=1 and ExpirationDate<getdate()

while (exists (select 1 from #tmpRule))
begin

select @id=IdRule,@RuleName=RuleName from #tmpRule
set @MessageMail = 'KYC Rule Expires - '+@RuleName
set @Body ='KYC Rule '+@RuleName+' has expired'

    update KYCRule set IdGenericStatus=2, DateOfLastChange=GETDATE(), EnterByIdUser=@EnterByIdUser where IdRule=@id

    set @dataxml = (select *  from kycrule WITH(NOLOCK) where idrule=@id FOR XML RAW)

    insert into [MAXILOG].[dbo].[GenericTableLog]
    (ObjectName,IdGeneric,Operation,XMLValues,DateOfLastChange,EnterByIdUser)
    values
    ('KYCRule',@id,'UPDATE',@dataxml,GETDATE(),@EnterByIdUser)

        EXEC msdb.dbo.sp_send_dbmail                          
                @profile_name=@EmailProfile,                                                     
                @recipients = @recipients,                                                          
                @body = @body,                                                           
                @subject = @MessageMail

delete from #tmpRule where IdRule=@id
end
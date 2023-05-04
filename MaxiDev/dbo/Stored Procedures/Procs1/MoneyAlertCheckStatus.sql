CREATE procedure [dbo].[MoneyAlertCheckStatus]
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

declare @TotCustomer int
declare @TotCustomerWT int
declare @TotCustomerNT int
declare @TotCustomerIOS int
declare @TotCustomerAND int

declare @TotBeneficiary int
declare @TotBeneficiaryWT int
declare @TotBeneficiaryNT int
declare @TotBeneficiaryIOS int
declare @TotBeneficiaryAND int

Declare @MessageMail nvarchar(max)
declare @Body nvarchar(max) = 'Money Alert Estatus'
Declare @recipients nvarchar (max)   = 'fsuarez@boz.mx'                     
Declare @EmailProfile nvarchar(max)   

Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'     

select @TotCustomerNT=count(1) from moneyalert.CustomerMobile with(nolock) where IdCustomerMobile>6 and Token is null
select @TotCustomerWT=count(1) from moneyalert.CustomerMobile with(nolock) where IdCustomerMobile>6 and Token is not null
select @TotCustomerAND=count(1) from moneyalert.CustomerMobile with(nolock) where IdCustomerMobile>6 and IdPhoneType=1
select @TotCustomerIOS=count(1) from moneyalert.CustomerMobile with(nolock) where IdCustomerMobile>6 and IdPhoneType=2

select @TotBeneficiaryNT=count(1) from moneyalert.BeneficiaryMobile with(nolock) where IdBeneficiaryMobile>13 and Token is null
select @TotBeneficiaryWT=count(1) from moneyalert.BeneficiaryMobile with(nolock) where IdBeneficiaryMobile>13 and Token is not null
select @TotBeneficiaryAND=count(1) from moneyalert.BeneficiaryMobile with(nolock) where IdBeneficiaryMobile>13  and IdPhoneType=1
select @TotBeneficiaryIOS=count(1) from moneyalert.BeneficiaryMobile with(nolock) where IdBeneficiaryMobile>13  and IdPhoneType=2

set @TotCustomer=@TotCustomerNT+@TotCustomerWT
set @TotBeneficiary=@TotBeneficiaryNT+@TotBeneficiaryWT



set @MessageMail = '
Total de Clientes: '+convert(varchar,@TotCustomer)+', IOS: '+convert(varchar,@TotCustomerIOS)+', Android: '+convert(varchar,@TotCustomerAND)+', Clientes con token: '+convert(varchar,@TotCustomerWT)+', Clientes sin token: ' +convert(varchar,@TotCustomerNT)+',

Total de Beneficiarios: '+convert(varchar,@TotBeneficiary)+', IOS: '+convert(varchar,@TotBeneficiaryIOS)+', Android: '+convert(varchar,@TotBeneficiaryAND)+', Beneficiarios con token: '+convert(varchar,@TotBeneficiaryWT)+', Beneficiarios sin token: ' +convert(varchar,@TotBeneficiaryNT)


declare @StoreProcedureName nvarchar(max)
Declare @Idsp int
declare @tot int
declare @UsageSP nvarchar(max) =''

declare @tableStore table
(
    idsp int identity(1,1),
    StoreProcedureName nvarchar(max)
)

insert into @tableStore
select distinct StoreProcedureName from moneyalert.StoreProcedureUsage with(nolock)    

while exists(select 1 from @tableStore)
begin
    select top 1 @Idsp=idsp,@StoreProcedureName=StoreProcedureName from @tableStore
    select @tot=count(1) from moneyalert.StoreProcedureUsage with(nolock) where StoreProcedureName=@StoreProcedureName and [dbo].[RemoveTimeFromDatetime](dateofinsert)=[dbo].[RemoveTimeFromDatetime](getdate()) group by StoreProcedureName
    set @UsageSP= @UsageSP+@StoreProcedureName+': '+convert(Varchar,isnull(@tot,0))+CHAR(13)+CHAR(10)
	set @tot=0
    delete from @tableStore where idsp=@Idsp;
end 

set @MessageMail=@MessageMail+'

Usage:
'
+@UsageSP


select @EmailProfile,@recipients,@body,@MessageMail
	

        EXEC msdb.dbo.sp_send_dbmail                          
            @profile_name=@EmailProfile,                                                     
            @recipients = @recipients,                                                          
            @body = @MessageMail,                                                           
            @subject = @body;
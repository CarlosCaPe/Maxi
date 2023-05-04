CREATE procedure [dbo].[st_SaveMountlyBankCommission]
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock) and ;</log>
</ChangeLog>
*********************************************************************/
set nocount on

begin try

declare @DateOfBankCommission datetime
declare @NewDateOfBankCommission datetime
declare @FactorNew float
declare @IdUser int

select @IdUser = convert(int, [dbo].[GetGlobalAttributeByName]('SystemUserID'))

select top 1 @DateOfBankCommission=DateOfBankCommission, @FactorNew=FactorNew
from 
    bankcommission with(nolock)
where 
    DateOfBankCommission<dbo.[RemoveTimeFromDatetime](getdate()-1) and active=1 
order by 
    DateOfBankCommission desc

set @NewDateOfBankCommission = DATEADD(month,1,@DateOfBankCommission)

--select @DateOfBankCommission,@NewDateOfBankCommission,@FactorNew,@IdUser

if (exists (select 1 from bankcommission with(nolock) where DateOfBankCommission=@NewDateOfBankCommission and factornew=0 and active=1)
or not exists (select 1 from bankcommission with(nolock) where DateOfBankCommission=@NewDateOfBankCommission)) and isnull(@FactorNew,0)!=0
begin
    exec st_SaveBankCommission @NewDateOfBankCommission,@IdUser,0,@FactorNew;    
    --select * from bankcommission where DateOfBankCommission=@NewDateOfBankCommission
end
end try
Begin Catch 
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveMountlyBankCommission',Getdate(),ERROR_MESSAGE());    
End Catch
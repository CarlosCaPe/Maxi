create procedure st_SaveMountlyPayerCommission
as
set nocount on
begin try

create table #PayerCommission
(
    Id int identity (1,1),
    idpayer int,
    idpaymenttype int,
    dateofpayercommission date, 
    commissionnew money
)

declare @DateOfPayerCommission datetime
declare @MounthActual datetime
declare @NewDateOfPayerCommission datetime
declare @CommissionNew money
declare @IdUser int
declare @IdPayer int
declare @IdPaymentType int
declare @i int

select @IdUser = convert(int, [dbo].[GetGlobalAttributeByName]('SystemUserID'))
select @DateOfPayerCommission = dbo.[RemoveTimeFromDatetime](getdate()-1)

SELECT @MounthActual = DATEADD(dd,-(DAY(@DateOfPayerCommission)-1),@DateOfPayerCommission)

insert into #PayerCommission
select idpayer,idpaymenttype,dateofpayercommission, commissionnew
    --top 1 @DateOfPayerCommission=DateOfPayerCommission, @CommissionNew=CommissionNew,@IdPayer=IdPayer,@IdPaymentType=IdPaymentType
from 
    [PayerCommission] 
where 
    DateOfpayerCommission=@MounthActual and active=1
order by 
    DateOfpayerCommission desc

while exists (select top 1 1 from #PayerCommission)
	Begin

    select top 1 @i= Id, @IdPayer = IdPayer, @IdPaymentType=IdPaymentType, @DateOfPayerCommission=dateofpayercommission,@CommissionNew=commissionnew
    from #PayerCommission

    set @NewDateOfPayerCommission = DATEADD(month,1,@DateOfPayerCommission)

    if (exists (select top 1 1 from [PayerCommission] where DateOfpayerCommission=@NewDateOfPayerCommission and idpayer=@idpayer and idpaymenttype=@idpaymenttype and commissionnew=0 and active=1)
    or not exists (select top 1 1 from [PayerCommission] where DateOfpayerCommission=@NewDateOfPayerCommission and idpayer=@idpayer and idpaymenttype=@idpaymenttype)) and isnull(@CommissionNew,0)!=0
        begin
            exec st_SavePayerCommission @Idpayer,@IdPaymentType,@NewDateOfPayerCommission,@IdUser,0,@CommissionNew            
            select @Idpayer,@IdPaymentType,@NewDateOfPayerCommission,@IdUser,@CommissionNew
        end   

    delete from #PayerCommission  where id=@i

    end    

    drop table #PayerCommission

end try
Begin Catch 
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveMountlyPayerCommission',Getdate(),ERROR_MESSAGE())    
End Catch
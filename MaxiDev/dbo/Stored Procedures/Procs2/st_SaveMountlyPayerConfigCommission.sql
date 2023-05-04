create procedure [dbo].[st_SaveMountlyPayerConfigCommission]
as
set nocount on
begin try

create table #PayerConfigCommission
(
    Id int identity (1,1),
    idpayerconfig int,    
    dateofPayerConfigCommission date, 
    commissionnew money
)

declare @DateOfPayerConfigCommission datetime
declare @MounthActual datetime
declare @NewDateOfPayerConfigCommission datetime
declare @CommissionNew money
declare @IdUser int
declare @idpayerconfig int
declare @i int

select @IdUser = convert(int, [dbo].[GetGlobalAttributeByName]('SystemUserID'))
select @DateOfPayerConfigCommission = dbo.[RemoveTimeFromDatetime](getdate()-1)

SELECT @MounthActual = DATEADD(dd,-(DAY(@DateOfPayerConfigCommission)-1),@DateOfPayerConfigCommission)

insert into #PayerConfigCommission
select idpayerconfig,dateofPayerConfigCommission, commissionnew
    --top 1 @DateOfPayerConfigCommission=DateOfPayerConfigCommission, @CommissionNew=CommissionNew,@idpayerconfig=idpayerconfig,@IdPaymentType=IdPaymentType
from 
    [PayerConfigCommission] 
where 
    DateOfPayerConfigCommission=@MounthActual and active=1
order by 
    DateOfPayerConfigCommission desc

while exists (select top 1 1 from #PayerConfigCommission)
	Begin

    select top 1 @i= Id, @idpayerconfig = idpayerconfig, @DateOfPayerConfigCommission=dateofPayerConfigCommission,@CommissionNew=commissionnew
    from #PayerConfigCommission

    set @NewDateOfPayerConfigCommission = DATEADD(month,1,@DateOfPayerConfigCommission)

    if (exists (select top 1 1 from [PayerConfigCommission] where DateOfPayerConfigCommission=@NewDateOfPayerConfigCommission and idpayerconfig=@idpayerconfig and commissionnew=0 and active=1)
    or not exists (select top 1 1 from [PayerConfigCommission] where DateOfPayerConfigCommission=@NewDateOfPayerConfigCommission and idpayerconfig=@idpayerconfig)) and isnull(@CommissionNew,0)!=0
        begin
            exec st_SavePayerConfigCommission @idpayerconfig,@NewDateOfPayerConfigCommission,@IdUser,0,@CommissionNew            
            --select @idpayerconfig,@NewDateOfPayerConfigCommission,@IdUser,@CommissionNew
        end   

    delete from #PayerConfigCommission  where id=@i

    end    

    drop table #PayerConfigCommission

end try
Begin Catch 
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveMountlyPayerConfigCommission',Getdate(),ERROR_MESSAGE())    
End Catch
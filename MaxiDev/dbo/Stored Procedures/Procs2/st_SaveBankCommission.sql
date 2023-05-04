--select * from [BankCommission]
CREATE procedure [dbo].[st_SaveBankCommission]
(
    @DateOfBankCommission datetime,
    @EnterByIdUser int,
    @FactorOld float,
    @Factornew float
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add ;</log>
</ChangeLog>
*********************************************************************/

begin try

--deshabilitar configuracion anterior
update BankCommission set active = 0 where DateOfBankCommission=@DateOfBankCommission;

--agregar configuracion actual

insert into BankCommission
([DateOfLastChange],[DateOfBankCommission],[EnterByIdUser],FactorOld,FactorNew,active)
values
(getdate(),@DateOfBankCommission,@EnterByIdUser,@FactorOld,@Factornew,1);

End Try
Begin Catch 
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveBankCommission',Getdate(),ERROR_MESSAGE());    
End Catch
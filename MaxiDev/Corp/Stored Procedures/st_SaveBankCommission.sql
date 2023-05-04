CREATE PROCEDURE [Corp].[st_SaveBankCommission]
(
    @DateOfBankCommission datetime,
    @EnterByIdUser int,
    @FactorOld float,
    @Factornew float--,
	--@managerID varchar(200) OUTPUT  
)
as

begin try

--deshabilitar configuracion anterior
update BankCommission set active = 0 where DateOfBankCommission=@DateOfBankCommission

--agregar configuracion actual

insert into BankCommission
([DateOfLastChange],[DateOfBankCommission],[EnterByIdUser],FactorOld,FactorNew,active)
values
(getdate(),@DateOfBankCommission,@EnterByIdUser,@FactorOld,@Factornew,1)



End Try
Begin Catch 
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SaveBankCommission]',Getdate(),ERROR_MESSAGE())    
End Catch



select * from [AgentCommisionCollection]

update [AgentCommisionCollection]
set IdCommisionCollectionConcept = 2
where IdAgentCommisionCollection =1



select * from  [SpecialCommissionBalance] order by 1 desc


select * from [AgentSpecialCommCollection] order by 1 desc

update [AgentSpecialCommCollection]
set ApplyDate = '2019-09-30 17:19:19.007'
where IdAgentSpecialCommCollection = 59481 



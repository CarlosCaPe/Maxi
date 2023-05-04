CREATE procedure [Corp].[st_GetAgentBankDeposit]
(
    @IsTablet bit
)
as
/********************************************************************
<Author> </Author>
<app>Corporate </app>
<Description> Consulta </Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="29/11/2019" Author="jzuniga">Se especifican campos de la tabla en consulta</log>
<log Date="17/09/2020" Author="jgomez">M00247 - Manejo de Subcuentas de Nevada y Nebraska en depósitos</log>
</ChangeLog>
*********************************************************************/
select IdAgentBankDeposit, BankName, AccountNumber, DateOfLastChange, EnterByIdUser, IdGenericStatus, IsTablet, SubAccountRequired--M00247
from agentbankdeposit with(nolock)
where idgenericstatus=1 and istablet= case when @IsTablet=0 then istablet else @IsTablet end
order by bankname
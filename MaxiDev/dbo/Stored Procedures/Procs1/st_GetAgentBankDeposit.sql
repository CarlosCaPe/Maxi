CREATE procedure [dbo].[st_GetAgentBankDeposit]
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
<log Date="10/09/2020" Author="adominguez">Se agregar campo SubAccountRequired para Req M00247</log>
</ChangeLog>
*********************************************************************/
select 
	IdAgentBankDeposit, 
	BankName, 
	AccountNumber, 
	DateOfLastChange, 
	EnterByIdUser, 
	IdGenericStatus, 
	IsTablet,
	SubAccountRequired--M00247
	from agentbankdeposit with(nolock)
	where idgenericstatus=1 
	and istablet= case when @IsTablet=0 then istablet else @IsTablet end
order by bankname
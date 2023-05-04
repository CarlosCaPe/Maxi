/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="12/12/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_GetTransactionsGatewayCable]
AS  

Set nocount on;
Begin try
	Select 
	t.IdAgent, AgentCode, ClaimCode, CustomerName, CustomerFirstLastName, CustomerSecondLastName, AgentName, DateOfTransfer, IdTransfer, t.Folio,
    PayerName, AmountInDollars, t.IdStatus, StatusName, PhysicalIdCopy, IdBeneficiary, c.IdCustomer
	from [Transfer] T with(nolock) 
	join Agent a with(nolock) on t.IdAgent = a.IdAgent
	join Payer p with(nolock) on t.IdPayer = p.IdPayer
	join [Status] s with(nolock) on t.IdStatus = s.IdStatus
	join Customer c with(nolock) on t.IdCustomer = c.IdCustomer
	where t.IdGateway = 12 and (t.IdStatus = 20 or t.IdStatus = 23)
	order by DateOfTransfer desc 
End try
Begin Catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetTransactionsGatewayCable',Getdate(),@ErrorMessage);
End catch

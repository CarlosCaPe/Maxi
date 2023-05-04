

CREATE procedure [dbo].[st_GetTransactionPontualForUpdateCheckStatus]    
(
    @IsDeposit bit = 0
)                  
AS 
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

--declare @PaymentTypeTable table
--(
--    IdPaymentType int
--)

--if (@IsDeposit=1)
--begin
-- insert into @PaymentTypeTable
-- select IdPaymentType from PaymentType where IdPaymentType=2
--end
--else
--begin
--insert into @PaymentTypeTable
-- select IdPaymentType from PaymentType where IdPaymentType!=2
--end    
       
Select 
	claimcode as AgentOrderReference,
	P.OrderId as OrderID
from [Transfer] A with(nolock)
	left join [PontualOrderID] P with(nolock) on P.IdTransfer =A.IdTransfer         
where IdGateway=28 and IdStatus in (23,25,28,40,29) --and IdPaymentType in (select IdPaymentType from @PaymentTypeTable)



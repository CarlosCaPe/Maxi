CREATE procedure [dbo].[st_GetTransactionInpamexForUpdateCheckStatus]    
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
 
declare @PaymentTypeTable table
(
    IdPaymentType int
);

if (@IsDeposit=1)
begin
 insert into @PaymentTypeTable
 select IdPaymentType from PaymentType with(nolock) where IdPaymentType=2;
end
else
begin
insert into @PaymentTypeTable
 select IdPaymentType from PaymentType with(nolock) where IdPaymentType!=2
end    
        
Select 3 as ReturnCodeType, claimcode as BenefReferenceID, ClaimCode  from [Transfer] with(nolock)     
where IdGateway=26 and IdStatus in (23,26,28,40,29) and IdPaymentType in (select IdPaymentType from @PaymentTypeTable)
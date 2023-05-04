
create procedure [dbo].[st_GetTransactionInpamexForUpdateCheckStatusV2]    
(
    @IsDeposit bit = 0
)                  
AS 
declare @PaymentTypeTable table
(
    IdPaymentType int
)

if (@IsDeposit=1)
begin
 insert into @PaymentTypeTable
 select IdPaymentType from PaymentType where IdPaymentType=2
end
else
begin
insert into @PaymentTypeTable
 select IdPaymentType from PaymentType where IdPaymentType!=2
end    
   
Set nocount on     
Select ClaimCode, IdStatus  from Transfer     
where IdGateway=26 and IdStatus in (23,26,28,40,29) and IdPaymentType in (select IdPaymentType from @PaymentTypeTable) and ClaimCode!=''
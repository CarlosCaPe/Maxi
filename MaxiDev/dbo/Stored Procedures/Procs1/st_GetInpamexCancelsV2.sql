CREATE procedure [dbo].[st_GetInpamexCancelsV2]  
(
    @IsDeposit bit = 0
) 
As
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
     
Set Nocount on 
Select  claimcode as noRemittance  from Transfer Where IdGateway=26 and IdStatus=25 and IdPaymentType in (select IdPaymentType from @PaymentTypeTable)

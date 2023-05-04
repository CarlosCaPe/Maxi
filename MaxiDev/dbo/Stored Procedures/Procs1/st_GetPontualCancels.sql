


create procedure [dbo].[st_GetPontualCancels]    
as    
Set Nocount on   
Select  
ClaimCode as AgentOrderReference,
'' as OrderID,
AmountInDollars as NetAmountSent,
CustomerFirstLastName  as SenderLastName,   
CustomerName as SenderFirstName
from Transfer Where IdGateway=28 and IdStatus=25





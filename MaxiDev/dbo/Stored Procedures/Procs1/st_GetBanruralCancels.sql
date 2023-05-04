CREATE procedure [dbo].[st_GetBanruralCancels]        
as        
Set Nocount on       
Select  ClaimCode,getdate() as CancellationDate  from Transfer Where IdGateway=13 and IdStatus=25  and idpayer<>4023        

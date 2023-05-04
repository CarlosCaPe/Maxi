CREATE procedure [dbo].[st_GetTransNetWorkCancels]    
as    
Set Nocount on   
Select  ClaimCode,getdate() as CancellationDate  from Transfer Where IdGateway=3 and IdStatus=25

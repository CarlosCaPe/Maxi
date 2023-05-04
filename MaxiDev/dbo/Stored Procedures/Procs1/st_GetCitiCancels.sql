CREATE procedure [dbo].[st_GetCitiCancels]        
as        
--Set Nocount on       
Select  ClaimCode from Transfer Where IdGateway=11 and IdStatus=25 --and 1=2

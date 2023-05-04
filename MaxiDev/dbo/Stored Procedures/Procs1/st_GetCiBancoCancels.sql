CREATE procedure [dbo].[st_GetCiBancoCancels]  
As  
Set Nocount on 
Select  claimcode as BenefReferenceID, ClaimCode  from Transfer Where IdGateway=10 and IdStatus=25

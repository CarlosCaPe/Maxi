CREATE  procedure [dbo].[st_GetBanruralUpdates]            
as            
Set Nocount on           
Select  ClaimCode  from Transfer Where IdGateway=13 and IdStatus in (25,23,26,35,40,29)     and idpayer<>4023        
--union all
--select claimcode from transfer where claimcode='BNL150201000001'

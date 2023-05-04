create procedure [dbo].[st_GetIntermexCancels]        
as        
Set Nocount on       
Select 
	ClaimCode			as vReferencia,
	'Customer request'	as vMotivoCancelacion
 from Transfer Where IdGateway=20 and IdStatus=25
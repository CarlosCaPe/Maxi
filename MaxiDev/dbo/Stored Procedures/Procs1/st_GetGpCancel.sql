create procedure [dbo].[st_GetGpCancel]                                    
as   
SELECT 
A.Claimcode as ConfirmationNumber,
'CWE' as CancellationReasonCode --CANCEL WITHOUT EXPLANATION / CANCELADO SIN EXPLICACION
from transfer A
Where A.IdGateway=34 and A.IdStatus=25
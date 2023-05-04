   CREATE PROCEDURE [dbo].[st_MaxiAlert_TransferInPendingGatewayResponse]
AS           
BEGIN 

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		SELECT 'Transfer en "Pending Gateway Response" por mas de 12 hrs' NameValidation,
			    'IdTranser:'+ISNULL(CAST(cte.IdTransfer AS VARCHAR), '')+'; ClaimCode:'+ISNULL(cte.ClaimCode, '') MsgValidation,
			   'Verificacion manual' FixDescription,
				'' Fix
          FROM (
		         SELECT IdTransfer, ClaimCode
				  FROM [Transfer] 
			     WHERE IdStatus IN (21)
				   AND DATEDIFF ( HOUR , GETDATE() , DateOfTransfer ) < -12 
		   ) cte

END






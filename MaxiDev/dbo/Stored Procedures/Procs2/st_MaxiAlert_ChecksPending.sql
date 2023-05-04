create PROCEDURE [dbo].[st_MaxiAlert_ChecksPending]
AS            
BEGIN 
SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 'Cheque en "Pending Gateway Response" por mas de 12 hrs' NameValidation,
			    'IdCheck:'+ISNULL(CAST(cte.idcheck AS VARCHAR), '')+'; ClaimCheck:'+ISNULL(cte.claimcheck, '') MsgValidation,
			   'Verificacion manual' FixDescription,
				'' Fix
          FROM (
		         SELECT idcheck, claimcheck
				  FROM checks
			     WHERE IdStatus IN (21)
				   AND DATEDIFF ( HOUR , GETDATE() , DateOfMovement ) < -12 
		   ) cte

END
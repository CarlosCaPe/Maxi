
CREATE PROCEDURE [dbo].[st_MaxiAlert_UnitellerConfirmationError]

AS            
BEGIN 

Declare @BeginDate dateTime= convert(date,GETDATE()-1)


SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
		   'Uniteller errores de confirmacion' NameValidation,
			Message+ ' ;MaxDateLog: '+ convert(varchar,MaxDateLog)  MsgValidation,
			'Reportal Uniteller' FixDescription,
			'' Fix	
	FROM ( 

			select Message, Max(DateLog) MaxDateLog
			from ServiceLogDetails (nolock) 
			where Category ='UNITELLERN' and DateLog>=@BeginDate and
				Message like 'UPDATE: The notification''s confirmation for %' and Message like '% has this response code 11104008'
			group by Message			

			) cet
			where MaxDateLog>=DATEADD(HOUR,22,@BeginDate)
			order by MaxDateLog
END

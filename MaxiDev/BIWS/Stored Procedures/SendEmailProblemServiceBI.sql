
-- =============================================
-- Author:		Jorge Gomez 
-- Create date: 10/07/2020
-- Description: SP para validar el tiempo de cada vez que falle el servicio de BI y mandar correo
-- M00235 - Mejoras en el manejo de error en la validación de la cuenta de BI por conectividad
-- =============================================

CREATE PROCEDURE [BIWS].[SendEmailProblemServiceBI]
as
Declare
@recipients varchar (50),
@DateLog time,
@ActualTime time,
@time time,
@DateIsEnable int,
@DateActual int,  
@result int,
@SendEmailProblemServiceBI int

SELECT  @recipients = [EmailReceiver] FROM [BIWS].[EmailConfigBI] with(nolock)
SELECT  @DateLog = [DateTime] from  [MAXILOG].[BIWS].[ErrorBiServiceLog] with(nolock) where IsEnable = 1 order by 1 desc
SELECT  @SendEmailProblemServiceBI = [Value] FROM [dbo].[GlobalAttributes] with(nolock) where  Name = 'IntervalTimerSendMSG'

SET @time = GETDATE()
SET @DateIsEnable = DATEDIFF(minute,0,@DateLog)
SET @DateActual = DATEDIFF(minute,0,@time)
SET @result = @DateActual -  @DateIsEnable  

if EXISTS (SELECT * from [MAXILOG].[BIWS].[ErrorBiServiceLog] WITH(NOLOCK) where IsEnable = 1) AND (@result >= @SendEmailProblemServiceBI)
	Begin 
	select 'si hay'
	EXEC msdb.dbo.sp_send_dbmail  
		@profile_name = 'Stage',  -- Agregar perfil configurado
		@recipients = @recipients,  
		@body = 'URGENTE Error de Conectividad con VPN de Banco Industrial',  
		@body_format = 'HTML',
		@subject = 'URGENTE Error de Conectividad con VPN de Banco Industrial' ;  
	END


	
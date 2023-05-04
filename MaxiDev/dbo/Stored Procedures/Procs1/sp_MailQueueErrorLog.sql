
CREATE PROCEDURE [dbo].[sp_MailQueueErrorLog] (@ErrorMessage VARCHAR(max), @Method VARCHAR(200), @Request VARCHAR(max)
)AS 
/********************************************************************
<Author>Fabián González</Author>
<app>MailSync</app>
<Description>Registro de un error en el log de Notificaciones.</Description>

<ChangeLog>
<log Date="16/11/2016" Author="fgonzalez"> Creación </log>
</ChangeLog>
*********************************************************************/
BEGIN

INSERT INTO [MAXILOG].[dbo].MailQueueErrorLog (LogDate, ErrorMessage, Method, Fullrequest)
VALUES (getdate(),@ErrorMessage, @Method, @Request)

END 

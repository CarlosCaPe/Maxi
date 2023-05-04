
CREATE PROCEDURE sp_GetPendingMail
AS
/********************************************************************
<Author>Fabián González</Author>
<app>MailSync</app>
<Description>Obtiene listado de correos pendientes por enviar.</Description>

<ChangeLog>
<log Date="15/11/2016" Author="fgonzalez"> Creación </log>
</ChangeLog>
*********************************************************************/
BEGIN 

SELECT mq.IdMailQueue, ReplyTo, MsgRecipient, MsgCC, MsgCCO, Subject, Body, CreateDate, SendDate, Content AS Template 
FROM MailQueue mq  WITH (NOLOCK)
LEFT JOIN MailQueueTemplate mt WITH (NOLOCK)
ON mt.TemplateId =mq.TemplateId
WHERE  (MailSent IS NULL OR Resend =1) AND SendDate <= getdate()


--Se obtienen los adjuntos 
SELECT ma.idMailQueue,FileName,Content FROM MailQueue mq WITH (NOLOCK)
INNER JOIN MailAttachment ma WITH (NOLOCK)
ON  ma.IdMailQueue= mq.IdMailQueue
WHERE  (MailSent IS NULL OR Resend =1) AND SendDate <= getdate()
UNION 
--Cuando el correo usa un template se agrega siempre el primer adjunto (logo de maxi)
SELECT mq.IdMailQueue,ma.FileName,ma.Content
FROM MailQueue mq WITH (NOLOCK)
INNER JOIN MailAttachment ma WITH (NOLOCK)
ON ma.TemplateId = mq.TemplateId
WHERE  (MailSent IS NULL OR Resend =1) AND SendDate <= getdate()
AND isnull(mq.TemplateId,'0') > 0



END 


CREATE PROCEDURE sp_CompletePendingMail(@idMailQueue INT)
AS
/********************************************************************
<Author>Fabián González</Author>
<app>MailSync</app>
<Description>Actualiza un correo como enviado</Description>

<ChangeLog>
<log Date="15/11/2016" Author="fgonzalez"> Creación </log>
</ChangeLog>
*********************************************************************/
BEGIN 

UPDATE MailQueue 
SET MailSent=getDATE(), resend=0
WHERE IdMailQueue = @idMailQueue

END 

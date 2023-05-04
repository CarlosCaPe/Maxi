CREATE PROCEDURE [Corp].[sp_MailQueue] 
(
@Source  	VARCHAR(255) = NULL,
@From 		VARCHAR(255) = NULL,
@To 		VARCHAR(255),
@CC	 		VARCHAR(255) = NULL,
@CCO 	 	VARCHAR(255) = NULL,
@Subject	VARCHAR(255),
@Body  	 	VARCHAR(max),
@Template 	INT = NULL,
@SendDate 	DATETIME = NULL  
)
AS
/********************************************************************
<Author>Fabián González</Author>
<app>MailSync</app>
<Description>Crea un registro para envío de correo electronico</Description>

<ChangeLog>
<log Date="15/11/2016" Author="fgonzalez"> Creación </log>
<log Date="21/03/2017" Author="fgonzalez"> Se obtiene el correo de la configuracion de MSDB </log>
<log Date="22/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
</ChangeLog>
*********************************************************************/
BEGIN 

DECLARE @Enviroment VARCHAR(200)
SET @Enviroment = [dbo].[GetGlobalAttributeByName]('Enviroment')

IF @Enviroment ='QA' BEGIN 
SET @From ='Environment_QA@maxitransfers.net'
END 

IF @Enviroment ='Dev' BEGIN 
SET @From ='Environment_Dev@maxitransfers.net'
END 

IF (@From IS NULL) BEGIN
	DECLARE @Profile VARCHAR(max)
	SELECT @Profile = [Value] FROM [dbo].[GlobalAttributes] WITH (NOLOCK) WHERE [Name] = 'EmailProfiler'
	
	SELECT @From = msdb.dbo.fn_getMailfromProfileName(@Profile) 
	
	SET @From = isnull(@From,'reports@maxitransfers.net')

END 
--Si no hay dato, se obtiene el nombre del Stored Procedure que se esta ejecutando
IF @Source IS NULL 
SELECT @Source = OBJECT_NAME(@@PROCID)
 
--Si no hay fecha de envío se pone la de ahora
IF @SendDate IS NULL 
SET @SendDate = getdate()

--Si no existe la plantilla no se usará para el envío
IF NOT EXISTS (SELECT 1 FROM [dbo].MailQueueTemplate WITH(NOLOCK) WHERE TemplateId =@Template)
SET @Template = NULL

INSERT INTO dbo.MailQueue (Source, ReplyTo, MsgRecipient, MsgCC, MsgCCO, Subject, Body, TemplateId, CreateDate, SendDate, MailSent)
VALUES (@Source, @From, @To, @CC, @CCO, @Subject, @Body, @Template, getdate(), @SendDate, NULL)

END

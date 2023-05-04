CREATE PROCEDURE st_SendIRDRequest
(
	@IdCheck	INT
)
AS
BEGIN
	DECLARE @HasError		BIT = 0,
			@ErrorMessage	VARCHAR(500),
			@Recipients		VARCHAR(200),
			@Subject		VARCHAR(200),
			@Description	VARCHAR(1000)

	SET @Recipients = dbo.GetGlobalAttributeByName('TempEmailIRD_Recipients')

	SELECT
		@Subject = CONCAT('IRD Request #', c.IdCheck),
		@Description = CONCAT(
			'El agente ', a.AgentCode,' ', a.AgentName,' esta solicitando re-procesar un cheque rechazado.',
			'<br>',
			'La informacion de este cheque es:',
			'<br>',
			'Numero de Cheque: ', c.CheckNumber,
			'<br>',
			'Numero de Cuenta: ', c.Account,
			'<br>',
			'Numero de Ruta: ', c.RoutingNumber,
			'<br>',
			'Monto del cheque: ', c.Amount,
			'<br><br>',
			'Hay que contactar al agente para avisarle que esta funcionlalidad no esta disponible por el momento. Se le hara llegar la Copia Legal de forma física a la Agencia')
	FROM Checks c WITH(NOLOCK)
		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = c.IdAgent
	WHERE c.IdCheck = @IdCheck

	--SELECT
	--	@Recipients,
	--	@Subject,
	--	@Description

	EXEC st_SendMaxiEmail 
		@Recipients,
		'',
		'',
		@Subject,
		@Subject,
		@Description,
		NULL,
		@HasError OUT,
		@ErrorMessage OUT

	IF @HasError = 1
		SET @ErrorMessage = 'Error al enviar correo electrónico / Error while send email'
	ELSE
		SET @ErrorMessage = 'El area de finanzas ha recibido su solicitud de re-procesamiento del cheque, lo estaremos contactando para más detalles / The finance area has received your request to reprocess this check, we will be contacting you for more details'

	SELECT @HasError HasError, @ErrorMessage ErrorMessage
END

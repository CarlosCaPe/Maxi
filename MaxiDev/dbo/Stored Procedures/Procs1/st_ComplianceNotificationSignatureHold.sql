CREATE Procedure [dbo].[st_ComplianceNotificationSignatureHold]
AS 
SET NOCOUNT ON

DECLARE @HasError BIT = 0;
DECLARE @MessageOut NVARCHAR(MAX)= '';

BEGIN TRY

	/*Paso 0: Inicializar variables*/
	DECLARE @IdUser INT;
	SET @IdUser = CONVERT(INT, [dbo].[GetGlobalAttributeByName]('SystemUserID'))

	/*1 --isespanishlenguage*/
	DECLARE @IsSpanishLanguage BIT = 0;

	/*Paso 1:Obtener las operciones en Verified Hold que tengan un Signature Hold correspondientes a la Agencia*/
	DECLARE @Agents TABLE
	(
		Id INT IDENTITY(1,1)
		,IdAgent INT
	);

	INSERT INTO @Agents
		select distinct T.IdAgent
		from transfer T with(nolock)
			join Agent A with(nolock) on T.IdAgent = A.IdAgent
			join TransferHolds H with(nolock) on T.IdTransfer = H.IdTransfer and H.IdStatus = 3 and H.IsReleased is null
		where T.IdStatus = 41
				and IdAgentStatus <>  2 /*Disabled*/
			order by T.IdAgent desc;

	/*Paso 2:Obtiene el mensaje adecauado  para la notificacion*/
	DECLARE @ComplianceProductMessage VARCHAR(MAX) = 'Please submit signed receipt of the above transactions';
	DECLARE @IdComplianceProduct INT = 0;
	SELECT @IdComplianceProduct = IdComplianceProduct
		FROM dbo.ComplianceProducts WITH(NOLOCK)
			WHERE  Name = @ComplianceProductMessage OR NameEn = @ComplianceProductMessage; 

	/*Paso 3: Generara cada una de las notificaciones*/
	while Exists(SELECT TOP 1 1 FROM @Agents)
	BEGIN
		
		DECLARE @IdAgent INT,	
			@IdAgentCommunication INT;

		/*Paso 2.1: Seleccionar agencia a trabajar*/
		Select Top 1 @IdAgent = IdAgent from @Agents;

		/*Paso 2.2: Crea notificacion*/
		DECLARE @IdTransfer INT = 0;
		EXEC dbo.st_CreateComplianceNotificationSignatureHold
			@IdAgent,
			@IdTransfer,
			@IdComplianceProduct,
			@IdUser,
			@IsSpanishLanguage;
			--,@RawMessage NVARCHAR(MAX) = NULL

		/*Paso 2.3: Borra agencia que se trabajó*/
		DELETE FROM @Agents WHERE IdAgent = @IdAgent;

	END

End Try 
Begin Catch
	 Set @HasError=1;
	 Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33);
	 Declare @ErrorMessage nvarchar(max);
	 Select @ErrorMessage=ERROR_MESSAGE();
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ComplianceNotificationSignatureHold',Getdate(),@ErrorMessage);
End Catch 

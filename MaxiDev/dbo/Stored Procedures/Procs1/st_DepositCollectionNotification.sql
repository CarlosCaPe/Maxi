CREATE PROCEDURE [dbo].[st_DepositCollectionNotification]
    @IdAgent Int
    ,@Deposit Money
    ,@CollectDate Datetime
    ,@HasError BIT OUTPUT
    ,@Message VARCHAR(MAX) OUTPUT
AS
/********************************************************************
<Author>snevarez</Author>
<app></app>
<Description>Creacion de notificaciones por porcentaje</Description>

<ChangeLog>
<log Date="17/11/2017" Author="Snevarez"> REQ_CO_001:Notificaciones de Agencias Suspendidas que Depositaron </log>
</ChangeLog>
*********************************************************************/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	SET ARITHABORT ON

	SET @HasError = 0;
	SET @Message = '';

    Begin try

	   /*Paso 0:  Obtener datos generales de la agencia*/
	   DECLARE @AgentCode NVARCHAR(MAX)=' '
	   DECLARE @IdAgentStatus INT
	   DECLARE @AgentStatusName NVARCHAR(MAX)=' '
	   DECLARE @AgentName NVARCHAR(MAX)=' '
	   DECLARE @IdAgentClass Int;

	   SELECT 
		  @AgentCode=[AgentCode]
		  , @IdAgentStatus=A.[IdAgentStatus]
		  , @AgentStatusName=UPPER([AgentStatus])
		  , @AgentName=[AgentName]
		  , @IdAgentClass = [IdAgentClass]
	   FROM [dbo].[Agent] A WITH (NOLOCK)
		  JOIN [dbo].[AgentStatus] S WITH (NOLOCK) ON A.[IdAgentStatus]=S.[IdAgentStatus]
			 WHERE [IdAgent] = @IdAgent;


	   /*Paso 1:  Validacion de estado de agencias sus pendidas (3-Suspended,4-Hold,7-Inactive)*/
	   IF (@IdAgentStatus=3 OR @IdAgentStatus=4 OR @IdAgentStatus=7)
	   BEGIN

		  DECLARE @MaxiCollectionDate  Datetime;
		  DECLARE  @DAYBACK INT = (CASE DATEPART(WEEKDAY,@CollectDate)  
			 WHEN 1 THEN -2 /*SUNDAY*/
			 WHEN 7 THEN -1 /*SATURDAY*/
			 ELSE 0 END);

		  -- #01 Se cambia nombre de variable para permitir Maxicollection obtener info del ultimo dia de cobranza
		  SET @MaxiCollectionDate = DATEADD(d,@DAYBACK,@CollectDate); 

		  /*Paso 2: Agencia esta en cobranza del dia actual*/
		  IF EXISTS(SELECT 1 FROM MaxiCollection WHERE IdAgent = @IdAgent AND dbo.RemoveTimeFromDatetime(dateofcollection)=dbo.RemoveTimeFromDatetime(@MaxiCollectionDate)) --#01
		  BEGIN

			 /*Paso 2.1: Obtener los depositos del dia.*/
			 DECLARE @DepositAmount Money = 0;
			 SET @DepositAmount = ISNULL((select 	
										  SUM(ISNULL(amount,0)) collectAmount
									   from agentdeposit d with (nolock) 
										  join agent a with (nolock) on a.idagent=d.idagent 
									   where 
										  dbo.RemoveTimeFromDatetime(d.DateOfLastChange)=dbo.RemoveTimeFromDatetime((@CollectDate)) 
										  --AND d.DateOfLastChange < @CollectDate /*????*/
										  and a.IdAgent = @IdAgent
									   group by d.idagent),0);

			 --SET @DepositAmount  = @DepositAmount + @Deposit; /*Fix: Se estaba considerando dos veces el ultimo deposito*/


			 /*Paso 2.2: Obtener los adeudo del dia*/
			 DECLARE @Spected Money = 0; 
			 SELECT
				@Spected = (ISNULL(m.AmountByCalendar,0) + ISNULL(m.AmountByCollectPlan,0)  + ISNULL(m.AmountByLastDay,0) )
			 FROM MaxiCollection AS m
				JOIN dbo.Agent a ON m.idagent=a.idagent
			 WHERE m.IdAgent = @IdAgent
				AND dbo.RemoveTimeFromDatetime(m.dateofcollection) = dbo.RemoveTimeFromDatetime(@MaxiCollectionDate); --#01


			 /*Paso 2.3: Definir porcentajes de evaluacion*/
			 DECLARE @Percentage Money = 0;
			 SET @Percentage = (
				CASE 
					   WHEN @IdAgentClass = 1 THEN 0.7
					   WHEN @IdAgentClass = 2 THEN 0.8
					   WHEN @IdAgentClass = 3 THEN 0.8
					   WHEN @IdAgentClass = 4 THEN 0.9
					   ELSE 0 
				END);

			 DECLARE @SpectedClass Money = (ISNULL(@Spected,0) * ISNULL(@Percentage,0));

			 /*Cuando lleguen al 50% y menos del 70% de su monto a depositar*/
			 DECLARE @Percentage50 Money = 0.5; 
			 DECLARE @Spected50 Money = (ISNULL(@SpectedClass,0) * ISNULL(@Percentage50,0));

			 /*Cuando lleguen al 70% y menos del porcentaje del que se liberarÃ­an de suspendidas, de acuerdo a su categorÃ­a (A, B, C y D) de su monto a depositar*/
			 DECLARE @Percentage70 Money = 0.7; 
			 DECLARE @Spected70 Money = (ISNULL(@SpectedClass,0) * ISNULL(@Percentage70,0));
	   
			 /*Porcentaje pagado al momento de enviar el email.*/
			 DECLARE @PercentagePayed Money = 0; 
			 SET @PercentagePayed = ROUND((@DepositAmount * 100) / @SpectedClass,2);

			 /*Porcentaje faltante para alcanzar el mÃ­nimo requerido.*/
			 DECLARE @PercentageCompleted Money = 100-@PercentagePayed; 


			 /*Paso 2.3.1: Validar notificaciones*/
			 /*@Deposit*/
			 DECLARE @Send BIT = 0;
			 IF ((@DepositAmount >= @Spected50) AND (@Deposit < @Spected70))
			 BEGIN
				/*>=50% And <70%*/
				IF EXISTS(SELECT TOP 1 1 FROM CollectionNotificationDeposit 
							 WHERE IdAgent = @IdAgent
								AND dbo.RemoveTimeFromDatetime(CollectDate) = dbo.RemoveTimeFromDatetime(@MaxiCollectionDate) 
								AND Percentage = @Percentage50 OR Percentage = @Percentage70)
				BEGIN
				    SET @Send = 0;
				    RETURN;
				END
				ELSE
				BEGIN
				    SET @Send = 1;
				    SET @Percentage = 0.5;
				END
			 END
			 ELSE IF @Deposit >= @Spected70
			 BEGIN
				/*>=70%*/
				 IF EXISTS(SELECT TOP 1 1 FROM CollectionNotificationDeposit 
							 WHERE IdAgent = @IdAgent
								AND dbo.RemoveTimeFromDatetime(CollectDate) = dbo.RemoveTimeFromDatetime(@MaxiCollectionDate) 
								AND Percentage = @Percentage70)
				BEGIN
				    SET @Send = 0;
				    RETURN;
				END
				ELSE
				BEGIN
				    SET @Send = 1;
				    SET @Percentage = 0.7;
				END
			 END
			 ELSE
			 BEGIN
				/*<50%*/
				SET @Send = 0;
			 END

			 /*Paso 2.4:*/
			 IF(@Send=1)
			 BEGIN

				/*Paso 2.4.1:Insecion de registro para control de notificaciones*/
				--INSERT INTO dbo.CollectionNotificationDeposit (IdAgent, CollectDate, Percentage) VALUES (@IdAgent,GETDATE(),@Percentage50);

				/*Paso 2.4.2:Generacion de notificacion*/
	   			DECLARE @Enviroment NVARCHAR(MAX)
				SET @Enviroment = [dbo].[GetGlobalAttributeByName]('Enviroment')

				DECLARE @recipients NVARCHAR(MAX);
				DECLARE @EmailProfile NVARCHAR(MAX);
				DECLARE @body NVARCHAR(MAX);
				DECLARE @Subject NVARCHAR(MAX);

				DECLARE @ProcID VARCHAR(200);
				SET @ProcID =OBJECT_NAME(@@PROCID);

				IF @Enviroment = 'Production'
				    SELECT @recipients = 'cob@maxi-ms.com';
				ELSE
				    SELECT @recipients = 'soportemaxi@boz.mx; mmendoza@maxi-ms.com';

				SELECT @Subject = 'Agent ' + ISNULL(@AgentCode,'') + ', ' + @AgentStatusName + ', Deposited $ '+ CONVERT(VARCHAR(12),@Deposit);
				SELECT @body = 'A payment of $ ' + CONVERT(VARCHAR(12),@Deposit) + ' was received for Agent '+ ISNULL(@AgentCode,'') + ' ' + @AgentName 
							 +', amount payable: ' + @AgentStatusName
							 + ', percentage paid at the time '+ CONVERT(VARCHAR(12),@PercentagePayed) + '%'
							 + ', missing percentage to reach the minimum required ' + CONVERT(VARCHAR(12),@PercentageCompleted)+ '%';



				SELECT @EmailProfile=Value FROM [dbo].[GlobalAttributes] WITH (NOLOCK) WHERE [Name] = 'EmailProfiler';
				INSERT INTO [dbo].[EmailCellularLog] (Number,Body,[Subject],[DateOfMessage]) VALUES (@recipients,@body,@subject,GETDATE());

				EXEC sp_MailQueue 
				    @Source   =  @ProcID,
				    @To 	  =  @recipients,
				    @Subject  =  @subject,
				    @Body  	  =  @body;

			 END

		  END
		  ELSE
		  BEGIN
			 Set @HasError = 0;
			 SET @Message = 'There is no scheduled collection for ' + CONVERT(VARCHAR(12),@MaxiCollectionDate,110);
			 RETURN
		  END
	   END
	   ELSE
	   BEGIN
		  Set @HasError = 0;
		  SET @Message = 'The agency is not suspended (Suspended,Hold,Inactive)';
		  RETURN
	   END


	End Try
	begin catch
		Set @HasError = 1;
		Set @Message = 'Error during the creation of the notification';

		Declare @ErrorMessage nvarchar(max);
		Select @ErrorMessage=ERROR_MESSAGE();
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_DepositCollectionNotification',Getdate(),'Agent:'+Convert(VARCHAR(250),@IdAgent)+','+@ErrorMessage);
	End Catch

END
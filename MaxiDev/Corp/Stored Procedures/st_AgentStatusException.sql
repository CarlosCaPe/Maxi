CREATE PROCEDURE [Corp].[st_AgentStatusException]
	@CollectDate Datetime,
    @IdAgent Int,
	@Deposit Money,
    @IdUser int
AS
/********************************************************************
<Author>Fabián González</Author>
<app>Corporativo</app>
<Description>Rehabilita Agencia si el deposito excede lo esperado</Description>

<ChangeLog>
<log Date="20/01/2017" Author="Snevarez"> Creación </log>
<log Date="17/04/2017" Author="fgonzalez" Change="01"> Se agrega validacion en sabados y domingos para @collectDate para MaxiCollection y no para AgentDeposit </log>
<log Date="16/05/2017" Author="fgonzalez" Change="02"> Se agrega validacion si no hay cobranza ese dia , se toma como monto esperado el balance </log>
</ChangeLog>
*********************************************************************/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ARITHABORT ON

Begin try

	/*Paso 0: La agencia es una excepcion*/
	DECLARE @Exception bit;
	DECLARE @MaxiCollectionDate DATETIME 
	
	SET  @Exception = ISNULL((SELECT Top 1 Exception FROM AgentException WITH (NOLOCK) Where IdAgent = @IdAgent Order by EnterDate Desc), 0);

	IF (@Exception = 0)
	BEGIN

		/*S54: Paso 0.1: Ajuste de fechas para fin de semana*/
			DECLARE  @DAYBACK INT = (CASE DATEPART(WEEKDAY,@CollectDate)  
				WHEN 1 THEN -2 /*SUNDAY*/
				WHEN 7 THEN -1 /*SATURDAY*/
				ELSE 0 END)
			
			-- #01 Se cambia nombre de variable para permitir Maxicollection obtener info del ultimo dia de cobranza
			SET @MaxiCollectionDate = DATEADD(d,@DAYBACK,@CollectDate); 
			
		/**/
		DECLARE @currentBalance MONEY 
		SELECT @currentBalance = Balance FROM AgentCurrentBalance WITH (NOLOCK) WHERE IdAgent = @IdAgent
		SET @currentBalance = isnull(@currentBalance,0)
		
		/*Paso 1: Agencia esta en cobranza del dia actual*/
		IF EXISTS(SELECT 1 FROM MaxiCollection WITH (NOLOCK) WHERE IdAgent = @IdAgent AND dbo.RemoveTimeFromDatetime(dateofcollection)=dbo.RemoveTimeFromDatetime(@MaxiCollectionDate)) --#01
		OR @currentBalance > 0
		BEGIN
			/*Paso 1.1: Agencia se encuentra Hold o Suspended*/
			--AgentStatus:	3=Suspended, 4=Hold
			IF EXISTS(SELECT 1 FROM Agent WITH (NOLOCK) WHERE IdAgent = @IdAgent AND (IdAgentStatus = 3  OR IdAgentStatus = 4))
			BEGIN		
				/*Paso 1.2: Obtener la cobranza del dia*/
				/*Paso 1.3: Obtener Clase de la agencia*/
				DECLARE @IdAgentClass int=0;
				DECLARE @AmountByCalendar Money = 0;
				DECLARE @AmountByCollectPlan Money = 0;
				DECLARE @AmountByLastDay Money = 0;
				DECLARE @CollectAmount Money = 0;
				DECLARE @Spected Money = 0;				

				SELECT
					/*1.3*/
					@IdAgentClass = a.IdAgentClass, 
					/*1.2*/
					@AmountByCalendar = ISNULL(AmountByCalendar,0) ,
					@AmountByLastDay = ISNULL(AmountByLastDay,0) , 
					@AmountByCollectPlan = ISNULL(AmountByCollectPlan,0) ,
					@CollectAmount = ISNULL(CollectAmount,0) ,
					/*---*/
					@Spected = (ISNULL(m.AmountByCalendar,0) + ISNULL(m.AmountByCollectPlan,0)  + ISNULL(m.AmountByLastDay,0) )
				FROM MaxiCollection AS m WITH (NOLOCK)
					JOIN dbo.Agent a WITH (NOLOCK) ON m.idagent=a.idagent
				WHERE m.IdAgent = @IdAgent
					AND dbo.RemoveTimeFromDatetime(m.dateofcollection)=dbo.RemoveTimeFromDatetime(@MaxiCollectionDate); --#01



				IF @spected = 0 BEGIN
				 --Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusException',Getdate(),'No hay Monto esperado de pago, se activará agencia: @IdAgent:'+Convert(VARCHAR,isnull(@IdAgent,0))+', @Deposit:'+Convert(VARCHAR,isnull(@Deposit,0)));
				 IF @currentBalance > 0 BEGIN 
				 	 SELECT	@IdAgentClass = idAgentClass FROM Agent WITH (NOLOCK) WHERE IdAgent = @idAgent
				 	 SET @spected = @currentBalance
				 END 
				END 
				
				
				/*Paso 1.4: Obtener los depositos de la agencia*/
				DECLARE @DepositAmount Money = 0;
				SET @DepositAmount = ISNULL((select 	
											SUM(ISNULL(amount,0)) collectAmount
										from agentdeposit  d with (nolock) 
											join agent a with (nolock) on a.idagent=d.idagent 
										where 
											dbo.RemoveTimeFromDatetime(d.DateOfLastChange)=dbo.RemoveTimeFromDatetime((@CollectDate)) 
											AND d.DateOfLastChange < @CollectDate /*20161214*/
										   --and [dbo].[GetDayOfWeek] (d.DateOfLastChange) not in (6,7)  --#01 Se comenta para permitir cobranza en fin de semana
											and a.IdAgent = @IdAgent
										group by d.idagent),0);



				/*Paso 1.5: Sumar el deposito al acumulado de depositos*/
				SET @DepositAmount  = @DepositAmount + @Deposit;

				/*Paso 1.5: Calcular porcentaje*/
				DECLARE @Percentage Money = 0;
				SET @Percentage = ((@DepositAmount*100) / @Spected);

				
				Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusException',Getdate(),'Antes ChangeStatus - @CollectDate: ' + convert(VARCHAR(max), @CollectDate));
				Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusException',Getdate(),'Antes ChangeStatus - DepositAmount: ' + convert(VARCHAR(max), @DepositAmount));
				Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusException',Getdate(),'Antes ChangeStatus - Deposit: ' + convert(VARCHAR(max), @Deposit));
				Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusException',Getdate(),'Antes ChangeStatus - Spected: ' + convert(VARCHAR(max), @Spected));

				/*Paso 1.5: Validar cambio de estado(Clase+porcentaje)*/
				DECLARE @ChangeStatus bit = 0;
				--1 - Clase A -70%
				--2 - Clase B – 80%
				--3 - Clase C - 80%
				--4 - Clase D – 90%
				SET @ChangeStatus = (
				CASE 
					WHEN (@IdAgentClass = 1 AND  @Percentage >= 70) THEN 1
					WHEN (@IdAgentClass = 2 AND  @Percentage >= 80) THEN 1
					WHEN (@IdAgentClass = 3 AND  @Percentage >= 80) THEN 1
					WHEN (@IdAgentClass = 4 AND  @Percentage >= 90) THEN 1
					ELSE 0 
				END);
				
				Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusException',Getdate(),'Antes ChangeStatus - Percentage: ' + convert(VARCHAR(max), @Percentage));
				

				IF (@ChangeStatus = 1)
				BEGIN
					Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusException',Getdate(),'Enter ChangeStatus - IdAgentClass: ' + convert(VARCHAR(max), @IdAgentClass));
					
					select @IdUser=convert(int,[dbo].[GetGlobalAttributeByName]('SystemUserID'))
					
					/*CGG: Si el Agente tiene Suspension por Cobranza se quita la suspension (solo de cobranza)*/
					IF EXISTS (SELECT 1
								FROM Corp.AgentSuspendedSubStatus
								WHERE IdAgent = @IdAgent AND Suspended = 1 AND IdMaxiDepartment = 3)
					BEGIN
						DECLARE @SuspCompliance BIT, @SuspAMLTraining BIT, @SuspAccRec BIT, @SuspFraudMonitor BIT, @SuspAgentAdmin BIT
						
						SELECT @SuspCompliance = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 1
						SELECT @SuspAMLTraining = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 2
						SELECT @SuspFraudMonitor = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 4
						SELECT @SuspAgentAdmin = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 5
						
						Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusException',Getdate(),'Enter ChangeStatus - IdAgentClass: ' + convert(VARCHAR(max), @IdAgentClass));
						
						EXEC [Corp].[st_AgentStatusChange] @IdAgent, 
															3, 
															@IdUser, 
															'Accounts Receivable - Suspend Released', 
															NULL, 
															@SuspCompliance, 
															@SuspAMLTraining, 
															0, 
															@SuspFraudMonitor, 
															@SuspAgentAdmin
						
					END
					
					
					/*CGG: Si ya no hay suspensiones por parte de otros departamentos se cambia a enabled*/
					IF NOT EXISTS(SELECT * FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND Suspended = 1)
					BEGIN
						EXEC [Corp].[st_AgentStatusChange]				
						@IdAgent,
						--@IdStatus,
						1,	/*Enabled*/
						@IdUser,
						--@Note,
						'Enabled by System';
						--@CreditAmount
						--,null;
					END
				
					
				END 
				--ELSE BEGIN
				   
				   --Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusException',Getdate(),CASE WHEN @ChangeStatus =1 THEN 'SI' else 'NO' END +' se activo agente: @IdAgent:'+Convert(VARCHAR,isnull(@IdAgent,0))+', @Deposit:'+Convert(VARCHAR,isnull(@Deposit,0))+', @DepositAmount:'+convert(VARCHAR,isnull(@DepositAmount,0))+', @Spected:'+Convert(VARCHAR,isnull(@Spected,0)));
				
				--END 
				/*Paso 1.5*/
			END
			/*Paso 1.1:*/
		END
		/*Paso 1*/
	END
	/*Paso 0*/

	End Try
	begin catch
		Declare @ErrorMessage nvarchar(max)
		Select @ErrorMessage=ERROR_MESSAGE()
			Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusException',Getdate(),'Agent:'+Convert(VARCHAR(200),@IdAgent)+','+@ErrorMessage);
	End Catch

END








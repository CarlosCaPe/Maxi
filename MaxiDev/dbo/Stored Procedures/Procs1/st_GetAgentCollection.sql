
CREATE PROCEDURE [dbo].[st_GetAgentCollection]
    @CollectionDate DATETIME 
AS   

/********************************************************************
<Author> Francisco Lara </Author>
<app></app>
<date>2016-06-13</date>
<Description>This stored is used for collection job at beginning of day</Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

	--Delaracion de variables
	DECLARE @DayOfPayment INT 
	DECLARE @DateYestarday DATETIME
	DECLARE @Today INT
	DECLARE @IdCalendarCollect INT
	DECLARE @AmountByCollectPlan MONEY
	DECLARE @Fee MONEY

	CREATE TABLE #CalendarCollect
	(
		[IdAgent] INT,
		[AmountByCalendar] MONEY,
		[AmountByLastDay] MONEY,
		[AmountByCollectPlan] MONEY,
		[IdAgentCollectType] INT,
		--agregado 
		[Deposit] BIT,
		[DepositAmount] MONEY
		--InCalendar bit
	);

	CREATE TABLE #DateYestardayCollect
	(
		[IdAgent] INT,
		[AmountByCalendar] MONEY,
		[AmountByLastDay] MONEY,
		[AmountByCollectPlan] MONEY,
		[IdAgentCollectType] INT
		--InCalendar bit
	);

	CREATE TABLE #CollectPlanCollect
	(
		[IdAgent] INT,
		[AmountByCalendar] MONEY,
		[AmountByLastDay] MONEY,
		[AmountByCollectPlan] MONEY,
		[IdAgentCollectType] INT,
		--InCalendar bit,
		[Fee] MONEY,
		[IdCalendarCollect] INT
	);
    
	--Inicializacion de variables
	SELECT   @DayOfPayment = [dbo].[GetDayOfWeek](@CollectionDate)
			,@CollectionDate = [dbo].[RemoveTimeFromDatetime](@CollectionDate)
			,@Today = [dbo].[GetDayOfWeek] (@CollectionDate)

	IF EXISTS(SELECT 1 FROM [dbo].[MaxiCollection] WITH (NOLOCK) WHERE [DateOfCollection]=@CollectionDate) -- Cobranza it's ready
		RETURN

	IF @Today=6 OR @Today=7 -- (Monday=1, Tuesday=2, Wednesday=3, ..., Sunday=7)
		RETURN

	IF @Today=1 -- Monday
		SET @DateYestarday=@CollectionDate-3
	ELSE 
		SET @DateYestarday=@CollectionDate-1

	--Obtener adeudo por agencia de acuerdo al calendario de pago

	INSERT INTO #CalendarCollect
		SELECT
			[IdAgent]
			, [Amount] [AmountByCalendar]
			, 0 [AmountByLastDay]
			, 0 [AmountByCollectPlan]
			, [IdAgentCollectType]
			, CASE WHEN ISNULL([DepositAmount],0)>0 THEN 1 ELSE 0 END [Deposit]
			, [DepositAmount]
		FROM (
			SELECT
				A.[IdAgent]
				, ISNULL((SELECT TOP 1 [Balance] FROM [dbo].[AgentBalance] WITH (NOLOCK) WHERE [DateOfMovement] < [dbo].[funLastPaymentDate](A.[IdAgent],@CollectionDate)+1 AND [IdAgent]=A.[IdAgent] ORDER BY [DateOfMovement] DESC), 0) [Amount]
				, [IdAgentCollectType]
				--agregado
				, (SELECT SUM([Amount]) [Deposit] FROM [dbo].[AgentDeposit] WITH (NOLOCK) WHERE [DateOfLastChange] >= [dbo].[funLastPaymentDate](A.[IdAgent], @CollectionDate)+1 AND [IdAgent] = A.[IdAgent]) [DepositAmount]
				FROM [dbo].[Agent] A WITH(NOLOCK)
				WHERE (
					[DoneOnSundayPayOn] = @DayOfPayment or    
					[DoneOnMondayPayOn] = @DayOfPayment or    
					[DoneOnTuesdayPayOn] = @DayOfPayment or    
					[DoneOnWednesdayPayOn] = @DayOfPayment or    
					[DoneOnThursdayPayOn] = @DayOfPayment or    
					[DoneOnFridayPayOn] = @DayOfPayment or    
					[DoneOnSaturdayPayOn] = @DayOfPayment)
      
			) T; --where round(Amount,2) >0

	--Obtener adeudo por agencia del dia anterior
	INSERT INTO #DateYestardayCollect
		SELECT
			[IdAgent]
			, SUM([AmountByCalendar]) [AmountByCalendar]
			, SUM([Amount])-SUM([CollectAmount]) [AmountByLastDay]
			, SUM([AmountByCollectPlan]) [AmountByCollectPlan]
			, [IdAgentCollectType]
		FROM (
			SELECT 
				M.[IdAgent]
				, 0 [AmountByCalendar]
				, [Amount] [Amount]
				, [CollectAmount]
				, 0 [AmountByCollectPlan]
				, A.[IdAgentCollectType]
			FROM [dbo].[MaxiCollection] M WITH (NOLOCK)
			JOIN [dbo].[Agent] A WITH (NOLOCK) ON M.[IdAgent]=A.[IdAgent]
			WHERE M.[IdAgent] NOT IN (SELECT [IdAgent] FROM #CalendarCollect)
				AND M.[DateOfCollection]=@DateYestarday--fecha de busqueda historico
		) T
	GROUP BY [IdAgent], [IdAgentCollectType]
	HAVING SUM([Amount])-SUM([CollectAmount])>0;
        

	--Obtener adeudo de cuentas por cobrar
	INSERT INTO #CollectPlanCollect
		SELECT 
			p.IdAgent
			, 0 [AmountByCalendar]
			, 0 [AmountByLastDay]
			, [Amount]+ISNULL(C.[Fee],0) [AmountByCollectPlan]
			, A.[IdAgentCollectType]
			, ISNULL(C.[Fee],0) [Fee]
			, [IdCalendarCollect]
		FROM [dbo].[CalendarCollect] P WITH (NOLOCK)
		LEFT JOIN [dbo].[AgentCollection] C WITH (NOLOCK) ON P.[IdAgent]=C.[IdAgent]
		JOIN [dbo].[Agent] A WITH (NOLOCK) ON A.[IdAgent]=P.[IdAgent]
		WHERE [dbo].[RemoveTimeFromDatetime]([PayDate])=[dbo].[RemoveTimeFromDatetime](@CollectionDate)
			AND ROUND([Amount]+ISNULL(C.[Fee],0),2) > 0;

	INSERT INTO [dbo].[MaxiCollection] ([IdAgent], [Amount], [AmountByCalendar], [AmountByLastDay], [AmountByCollectPlan], [CollectAmount], [IdAgentCollectType], [DateOfCollection])
		SELECT
			[IdAgent]
			, [TOT].[AmountByCalendar] + [AmountByLastDay] + [AmountByCollectPlan] [AmountTot]
			, [AmountByCalendar]
			, [AmountByLastDay]
			, [AmountByCollectPlan] 
			, [CollectAmount]
			, [IdAgentCollectType]
			, [CollectionDate]
		FROM (
			SELECT
				[IdAgent]
				, [AmountByCalendar]
				, [AmountByLastDay]
				, [AmountByCollectPlan]
				,0 [CollectAmount]
				, [IdAgentCollectType]
				, @CollectionDate [CollectionDate]
			FROM (
				SELECT
					[IdAgent]
					, SUM([AmountByCalendar]) [AmountByCalendar]
					, SUM([AmountByLastDay]) [AmountByLastDay]
					, SUM([AmountByCollectPlan]) [AmountByCollectPlan]
					, [IdAgentCollectType]
				FROM (
					SELECT [IdAgent], [AmountByCalendar], [AmountByLastDay], [AmountByCollectPlan], [IdAgentCollectType] FROM #CalendarCollect
					UNION ALL
					SELECT [IdAgent], [AmountByCalendar], [AmountByLastDay], [AmountByCollectPlan], [IdAgentCollectType] FROM #DateYestardayCollect 
					UNION ALL
					SELECT [IdAgent], [AmountByCalendar], [AmountByLastDay], [AmountByCollectPlan], [IdAgentCollectType] FROM #CollectPlanCollect 
					) T
				GROUP BY [IdAgent], [IdAgentCollectType]
				) T
			)TOT
		WHERE ROUND([AmountByCalendar] + [AmountByLastDay] + [AmountByCollectPlan], 2) > 0;


	--proceso de ajuste de balance de cuentas por cobrar
	BEGIN TRY

		--Fix Depositos
		UPDATE [AgentCollectionRevision]
			SET [Revision]=T.[Deposit]
			, [AgentCollectionRevision].[DepositAmount]=ISNULL(T.[DepositAmount],0)
		FROM (SELECT [IdAgent], [Deposit], [DepositAmount] FROM #CalendarCollect WHERE [IdAgent] IN (SELECT [IdAgent] FROM [AgentCollectionRevision] WITH(NOLOCK) )) T
		WHERE [AgentCollectionRevision].[IdAgent] = T.[IdAgent];

		INSERT INTO [AgentCollectionRevision] ([IdAgent], [Revision], [DepositAmount])
			SELECT [IdAgent], [Deposit], ISNULL([DepositAmount],0) FROM #CalendarCollect WHERE [IdAgent] NOT IN (SELECT [IdAgent] FROM [AgentCollectionRevision] WITH(NOLOCK));

		DECLARE @HasErrorTmp BIT
		DECLARE @MessageTmp VARCHAR(MAX)
		DECLARE @Date DATETIME
		DECLARE @iduser INT

		SET @iduser=CONVERT(INT, [dbo].[GetGlobalAttributeByName]('SystemUserID'))

		WHILE EXISTS(SELECT 1 FROM #CollectPlanCollect)
		BEGIN
			SELECT TOP 1 @IdCalendarCollect=IdCalendarCollect FROM #CollectPlanCollect

			EXEC [dbo].[st_ApplyCalendarCollection]
						@IdCalendarCollect,
						@IdUser,
						1,          --isespanishlenguage
						@HasErrorTmp,
						@MessageTmp;

			DELETE #CollectPlanCollect WHERE [IdCalendarCollect]=@IdCalendarCollect;
		END
    
	END TRY
	BEGIN CATCH                                                         
		DECLARE @ErrorMessage nvarchar(max)
		SELECT @ErrorMessage=ERROR_MESSAGE()
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_GetAgentCollection', GETDATE(), @ErrorMessage);
	END CATCH

	--Calcular Detalle de agencia
	INSERT INTO [dbo].[MaxiCollectionDetail]
		SELECT DISTINCT [IdAgent], [DateOfCollection], [dbo].[fn_GetDateOfDebit]([IdAgent], @CollectionDate), [dbo].[fn_GetLNPD]([IdAgent], @CollectionDate) FROM [MaxiCollection] WITH(NOLOCK) WHERE [DateOfCollection]=@CollectionDate;


CREATE PROCEDURE [dbo].[st_ApplySpecialCommission]
@Simulation bit,
@CurrentDate datetime= null
AS

/********************************************************************
<Author> Unknown </Author>
<app> Corporativo </app>
<Description> Aplica Comisiones Especiales </Description>

<ChangeLog>
<log Date="04/10/2022" Author="cgarcia">MP-1208 - Se agrega consulta de Paises relacionados a la regla de comisiones epseciales</log>
</ChangeLog>

*********************************************************************/

IF (@CurrentDate is null)
BEGIN
	SET @CurrentDate =Convert(date,getDate())
END

Declare @BeginDate datetime = DATEADD(day,(day(@CurrentDate)*-1)+1,@CurrentDate)
DECLARE @EndDate datetime = DATEADD(month,1,@BeginDate)

IF @Simulation=1
	Select @CurrentDate '@CurrentDate',@BeginDate '@BeginDate',@EndDate '@EndDate'

SELECT 
	SC.[IdSpecialCommissionRule],
	SC.[BeginDate],
	DATEADD(day,1,SC.[EndDate]) EndDate,
	SC.[IdAgent],
	isnull(SCC.IdCountry, SC.[IdCountry]) AS IdCountry,
	SC.[IdOwner],
	SC.[ApplyForTransaction],
	SC.Accumulated,
	SC.Description
INTO #tempSpecialCommission
FROM [dbo].[SpecialCommissionRule] SC WITH(NOLOCK) LEFT JOIN
	Corp.SpecialCommissionRuleRelCountry SCC WITH(NOLOCK) ON SCC.IdSpecialCommissionRule = SC.IdSpecialCommissionRule
WHERE SC.IdGenericStatus=1 AND SC.IdUserAuthorizedBy is not null
	AND (@BeginDate<DATEADD(day,1,SC.[EndDate]) OR SC.EndDate is null) AND @EndDate>SC.BeginDate

IF @Simulation=1
	SELECT * FROM #tempSpecialCommission

SELECT DISTINCT IdAgent, IdOwner
INTO #Agents
FROM
	(
		SELECT DISTINCT A.IdAgent, A.IdOwner from  #tempSpecialCommission T
			inner join Agent A on A.IdAgent=T.IdAgent
	UNION
		SELECT DISTINCT A.IdAgent, A.IdOwner from  #tempSpecialCommission T
			inner join Agent A on A.IdOwner=T.IdOwner
	)L
WHERE L.IdAgent is not null

IF @Simulation=1
	SELECT * FROM #Agents

SELECT SUM(L.number) number, L.IdAgent, L.IdOwner, L.IdCountry, L.OperationDate
INTO #TempTransactions
FROM
	(
			SELECT 1 number, T.IdAgent, A.IdOwner, CC.IdCountry, Convert(date,T.DateOfTransfer) OperationDate
			FROM Transfer  t With (Nolock)    
			join agent a on t.idagent=a.idagent
			join CountryCurrency CC on CC.IdCountryCurrency =T.IdCountryCurrency
			where T.DateOfTransfer>=@BeginDate and T.DateOfTransfer<@EndDate and  T.IdAgent in (SELECT IdAgent from  #Agents)
		UNION ALL
			SELECT 1 number, T.IdAgent, A.IdOwner, CC.IdCountry, Convert(date,T.DateOfTransfer) OperationDate
			FROM TransferClosed  t With (Nolock)    
			join agent a on t.idagent=a.idagent
			join CountryCurrency CC on CC.IdCountryCurrency =T.IdCountryCurrency
			where T.DateOfTransfer>=@BeginDate and T.DateOfTransfer<@EndDate and  T.IdAgent in (SELECT IdAgent from  #Agents)
		UNION ALL
			Select  -1 number, T.IdAgent, A.IdOwner, CC.IdCountry, Convert(date,T.DateStatusChange) OperationDate
			from Transfer T
			join agent a on t.idagent=a.idagent
			join CountryCurrency CC on CC.IdCountryCurrency =T.IdCountryCurrency
			where T.DateStatusChange>=@BeginDate and T.DateStatusChange<@EndDate and T.IdStatus in (31,22) and  T.IdAgent in (SELECT IdAgent from  #Agents)
		UNION ALL
			Select -1 number, T.IdAgent, A.IdOwner, CC.IdCountry, Convert(date,T.DateStatusChange) OperationDate
			from TransferClosed T
			join agent a on t.idagent=a.idagent
			join CountryCurrency CC on CC.IdCountryCurrency =T.IdCountryCurrency
			where T.DateStatusChange>=@BeginDate and T.DateStatusChange<@EndDate and T.IdStatus in (31,22) and  T.IdAgent in (SELECT IdAgent from  #Agents)
	)L
GROUP By L.IdAgent, L.IdOwner, L.IdCountry, L.OperationDate

IF @Simulation=1
	SELECT * FROM #TempTransactions order by IdAgent, OperationDate

Declare @TempIdSpecialCommissionRule int,
	@TempBeginDate date,
	@TempEndDate date,
	@TempIdAgent int,
	@TempIdCountry int,
	@TempIdOwner int,
	@TempApplyForTransaction bit,
	@TempAccumulated bit,
	@TempCommission money,
	@TempGoal int,
	@TempFrom int,
	@TempTo int,
	@TempNumberTransactions int,
	@TempDescription varchar(max)

DECLARE @Balance TABLE(
	[IdAgent] [int] NOT NULL,
	[DateOfMovement] [datetime] NOT NULL,
	NumberTransactions INT NOT NULL,
	[Commission] [money] NOT NULL,
	[IdSpecialCommissionRule] [int] NOT NULL,
	[DateOfApplication] [datetime] NOT NULL
)

SELECT TOP 1
	@TempIdSpecialCommissionRule=[IdSpecialCommissionRule],
	@TempBeginDate=[BeginDate],
	@TempEndDate=[EndDate],
	@TempIdAgent=[IdAgent],
	@TempIdCountry=[IdCountry],
	@TempIdOwner=[IdOwner],
	@TempApplyForTransaction=[ApplyForTransaction],
	@TempAccumulated=[Accumulated],
	@TempDescription= Description
FROM #tempSpecialCommission

WHILE (@TempIdSpecialCommissionRule is not null)
BEGIN
	
	SET @TempNumberTransactions=null	

	IF @Simulation=1
		SELECT 
		@TempIdSpecialCommissionRule '@TempIdSpecialCommissionRule',
		@TempDescription '@TempDescription',
		@TempBeginDate '@TempBeginDate',
		@TempEndDate '@TempEndDate',
		@TempIdAgent '@TempIdAgent',
		@TempIdCountry '@TempIdCountry',
		@TempIdOwner '@TempIdOwner',
		@TempApplyForTransaction '@TempApplyForTransaction',
		@TempAccumulated '@TempAccumulated'

	SET @TempNumberTransactions=
						(SELECT SUM(T.number)
						FROM #TempTransactions T 
						WHERE (@TempIdAgent IS NULL or T.IdAgent=@TempIdAgent) AND (@TempIdOwner IS NULL or T.IdOwner=@TempIdOwner ) AND (@TempIdCountry IS NULL or T.IdCountry=@TempIdCountry) AND T.OperationDate>= @TempBeginDate AND (@TempEndDate IS NULL or T.OperationDate<@TempEndDate))
	SET @TempNumberTransactions= ISNULL(@TempNumberTransactions,0)
	
	if ((SELECT count(1) FROM [dbo].[SpecialCommissionRuleRanges] R	WHERE R.[IdSpecialCommissionRule]=@TempIdSpecialCommissionRule)=1)
		BEGIN
			SELECT @TempCommission=R.[Commission], @TempGoal=R.[Goal],@TempFrom= R.[From],@TempTo= R.[To]
			FROM [dbo].[SpecialCommissionRuleRanges] R
			WHERE R.[IdSpecialCommissionRule]=@TempIdSpecialCommissionRule
				AND (R.Goal=0 or @TempNumberTransactions>=R.Goal)
		END
	ELSE
		BEGIN
			IF(@TempAccumulated= 0)
				BEGIN
					SELECT TOP 1 @TempCommission=R.[Commission], @TempGoal=R.[Goal],@TempFrom= R.[From],@TempTo= R.[To]
					FROM [dbo].[SpecialCommissionRuleRanges] R
					WHERE R.[IdSpecialCommissionRule]=@TempIdSpecialCommissionRule
						AND R.[Goal]<=@TempNumberTransactions
					ORDER By R.[Goal] desc
				END
			ELSE
				BEGIN
					IF(@TempApplyForTransaction=0)
					BEGIN
						SET @TempFrom=0
						SET @TempTo=0
						SELECT  @TempCommission=SUM(R.[Commission]), @TempGoal=Max(R.[Goal])
						FROM [dbo].[SpecialCommissionRuleRanges] R
						WHERE R.[IdSpecialCommissionRule]=@TempIdSpecialCommissionRule
							AND R.[Goal]<=@TempNumberTransactions
					END
				END
		END

	IF @Simulation=1
		SELECT '',
				@TempNumberTransactions '@TempNumberTransactions',
				@TempCommission '@TempCommission',
				@TempGoal '@TempGoal',
				@TempFrom '@TempFrom',
				@TempTo '@TempTo'

	IF (ISNULL(@TempCommission,0)!=0)
	BEGIN
		
				DELETE @Balance

				INSERT INTO @Balance ([IdAgent]
								   ,[DateOfMovement]
								   ,NumberTransactions
								   ,[Commission]
								   ,[IdSpecialCommissionRule]
								   ,[DateOfApplication])
				SELECT 
					IdAgent, 
					GetDate() DateOfMovement,
					number TransacionsNumber, 
					dbo.fnCalculateSpecialCommission(@TempApplyForTransaction,@TempCommission,@TempFrom,@TempTo,number) CommissionResult, 
					@TempIdSpecialCommissionRule, 
					DateAdd(MINUTE,-1,@EndDate) DateOfApplication
				FROM 
					(
						SELECT LA.IdAgent, ISNULL(LT.number,0) number
						FROM
						(
							SELECT A.IdAgent
							FROM #Agents A
							WHERE (@TempIdAgent IS NULL or A.IdAgent=@TempIdAgent) AND (@TempIdOwner IS NULL or A.IdOwner=@TempIdOwner )
						) LA
						left Join 
						(
							SELECT T.IdAgent, SUM (T.number) number
							FROM #TempTransactions T 
									WHERE (@TempIdAgent IS NULL or T.IdAgent=@TempIdAgent) AND (@TempIdOwner IS NULL or T.IdOwner=@TempIdOwner ) AND (@TempIdCountry IS NULL or T.IdCountry=@TempIdCountry) AND T.OperationDate>= @TempBeginDate AND (@TempEndDate IS NULL or T.OperationDate<@TempEndDate)
							GROUP BY T.IdAgent
						) LT on LT.IdAgent=LA.IdAgent
					)L1

			
			
			--Fix por peticion de Miguel				
			IF(@TempIdAgent IS NULL and @TempIdOwner IS NOT NULL )
			BEGIN

				IF @Simulation=1
				SELECT '','All agents', NumberTransactions, [IdAgent] ,[DateOfMovement] ,[Commission],[IdSpecialCommissionRule],[DateOfApplication]
				FROM @Balance 

				DELETE @Balance WHERE IdAgent not in (				
														SELECT top 1  B.IdAgent
														FROM @Balance B
															inner join Agent A on A.IdAgent=B.IdAgent
															Where A.IdAgentStatus in (1,4,3,7)
														order by A.AgentCode asc)
				IF (@TempApplyForTransaction=1)
				BEGIN 
					UPDATE @Balance SET [Commission] =dbo.fnCalculateSpecialCommission(@TempApplyForTransaction,@TempCommission,@TempFrom,@TempTo,@TempNumberTransactions) 
				END
			END

			IF @Simulation=1
				SELECT '','Inserted', NumberTransactions, [IdAgent] ,[DateOfMovement] ,[Commission],[IdSpecialCommissionRule],[DateOfApplication]
				FROM @Balance WHERE Commission>0

			IF @Simulation=0
			BEGIN
				INSERT INTO [dbo].[SpecialCommissionBalance]
								   ([IdAgent]
								   ,[DateOfMovement]
								   ,[Commission]
								   ,[IdSpecialCommissionRule]
								   ,[DateOfApplication])
				SELECT [IdAgent] ,[DateOfMovement] ,[Commission],[IdSpecialCommissionRule],[DateOfApplication]
				FROM @Balance WHERE Commission>0
			END
		
	END

	
	DELETE #tempSpecialCommission WHERE [IdSpecialCommissionRule]=@TempIdSpecialCommissionRule AND isnull([IdCountry], 0) = isnull(@TempIdCountry, 0)
	
	SET @TempIdSpecialCommissionRule= null
	SET @TempCommission =null
	SET @TempGoal =null
	SET @TempFrom =null
	SET @TempTo =null
	
	SELECT TOP 1
	@TempIdSpecialCommissionRule=[IdSpecialCommissionRule],
	@TempBeginDate=[BeginDate],
	@TempEndDate=[EndDate],
	@TempIdAgent=[IdAgent],
	@TempIdCountry=[IdCountry],
	@TempIdOwner=[IdOwner],
	@TempApplyForTransaction=[ApplyForTransaction],	
	@TempAccumulated=[Accumulated],
	@TempDescription= Description
	FROM #tempSpecialCommission

END



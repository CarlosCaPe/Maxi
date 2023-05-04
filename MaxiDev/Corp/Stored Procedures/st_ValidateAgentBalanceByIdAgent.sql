CREATE PROCEDURE [Corp].[st_ValidateAgentBalanceByIdAgent]
	@IdAgent INT,
	@DateOfMovement datetime
AS

/********************************************************************
<Author>César García</Author>
<app>---</app>
<Description>Procedimiento almacenado que valida descuadres en balance de agente.</Description>

<ChangeLog>
</ChangeLog>
*********************************************************************/

BEGIN

	DECLARE @AgentCode VARCHAR(100)
	
	DECLARE @tmpAgentBalanceVal TABLE 
	(
		id			   int identity (1,1),--#1
		IdAgentBalance INT NOT NULL,
		IdAgent        INT NOT NULL,
		TypeOfMovement NVARCHAR (max) NOT NULL,
		DateOfMovement DATETIME NOT NULL,
		Amount         MONEY NOT NULL,
		Reference      NVARCHAR (max) NOT NULL,
		[Description]  NVARCHAR (max) NOT NULL,
		Country        NVARCHAR (max) NOT NULL,
		Commission     MONEY NOT NULL,
		DebitOrCredit  NVARCHAR (max) NOT NULL,
		Balance        MONEY NOT NULL,
		IdTransfer     INT NULL,
		FxFee          MONEY NOT NULL,
		IsMonthly      BIT DEFAULT ((0)) NULL
	)
	
	SELECT @AgentCode = A.AgentCode + ' ' + A.AgentName
	FROM Agent A WITH(NOLOCK)
	WHERE A.IdAgent = @IdAgent
	
	DECLARE @PrevMovementDate DATE
	
	SELECT TOP 1 @PrevMovementDate = MovementDate
	FROM 
	(
	SELECT  DISTINCT convert(DATE, DateOfMovement) AS MovementDate 
	FROM AgentBalance 
	WHERE DateOfMovement < @DateOfMovement 
		AND IdAgent = @IdAgent 
	) A
	ORDER BY A.MovementDate DESC	
	
	

	INSERT INTO @tmpAgentBalanceVal
		SELECT * 
		FROM AgentBalance with (nolock)
		WHERE IdAgent=@IdAgent
			and DateOfMovement>=@PrevMovementDate
		ORDER BY DateOfMovement

	DECLARE @TmpAgBalVal TABLE 
	(
		Balance1	   money not null,
		id			   int,--#1
		IdAgentBalance INT NOT NULL,
		IdAgent        INT NOT NULL,
		TypeOfMovement NVARCHAR (max) NOT NULL,
		DateOfMovement DATETIME NOT NULL,
		Amount         MONEY NOT NULL,
		Reference      NVARCHAR (max) NOT NULL,
		[Description]  NVARCHAR (max) NOT NULL,
		Country        NVARCHAR (max) NOT NULL,
		Commission     MONEY NOT NULL,
		DebitOrCredit  NVARCHAR (max) NOT NULL,
		Balance        MONEY NOT NULL,
		IdTransfer     INT NULL,
		FxFee          MONEY NOT NULL,
		IsMonthly      BIT DEFAULT ((0)) NULL
	)


	declare @Max int=(select MAX(id) from @tmpAgentBalanceVal)--#1
	declare @Ids int=1

	while (@Ids<=@Max)
	begin
		if (@Ids=1)
		begin
			declare @Balance1 money=0.00

			insert into @TmpAgBalVal
				SELECT Balance1=@Balance1,* 
				FROM @tmpAgentBalanceVal ab WHERE IdAgent=@IdAgent and id=@Ids
				ORDER BY DateOfMovement

			set @Ids=@Ids+1
		end

		else
		begin
			insert into @TmpAgBalVal
				SELECT Balance1=(SELECT sum (Amount*CASE WHEN DebitOrCredit='Credit' THEN -1 ELSE 1 END) FROM  @tmpAgentBalanceVal ab2 WHERE ab2.IdAgent =ab.idAgent AND ab2.IdAgentBalance = ab.idAgentBalance)+
					(select Balance FROM @tmpAgentBalanceVal ab where id=(@Ids-1)) ,* 
				FROM @tmpAgentBalanceVal ab WHERE IdAgent=@IdAgent and id=@Ids
				ORDER BY DateOfMovement

			set @Ids=@Ids+1
		end
	end 

--	select Balance1,IdAgentBalance,IdAgent,TypeOfMovement,DateOfMovement,Amount,Reference,[Description],Country,Commission,DebitOrCredit,Balance,IdTransfer,FxFee,IsMonthly 
--	from @TmpAgBalVal


	declare @Balance money
	declare @IdAB1 int
	declare @Num1 int=2
	


	while (@Num1<=@Max)
	begin
	
		set @Balance=(select Balance from @TmpAgBalVal where id=@Num1)

		if (@Balance != (select Balance1 from @TmpAgBalVal where id=@Num1))
		begin
			set @IdAB1=(select IdAgentBalance from @TmpAgBalVal where id=@Num1)
			select CAST(0 AS BIT) AS BalanceCorrecto, 'Id Balance ' + CAST(@IdAB1 AS NVARCHAR(20)) + ' is incorrect for Agent' + @AgentCode as Resultado
			Return
		end
		else 
		begin
			delete from @TmpAgBalVal where id=@Num1
		end

		set @Num1=@Num1+1
	end
	
	SELECT CAST(1 AS BIT) AS BalanceCorrecto, 'Balance is correct for Agent ' + @AgentCode AS Resultado

END



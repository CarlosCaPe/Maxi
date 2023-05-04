
CREATE PROCEDURE [Soporte].[sp_ValidateAgentBalanceByIdAgent_alt]
	@IdAgent INT,
	@DateOfMovement datetime,
	@IsCorrect bit output
AS

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que valida descuadres en balance de agente.</Description>

<ChangeLog>
<log Date="17/07/2017" Author="jdarellano">Creación</log>
<log Date="19/04/2018" Author="jdarellano" Name="#1">Mejoras para el proceso de validación de los balances.</log>
<log Date="02/01/2020" Author="jdarellano" Name="#2">Se agrega variable de salida tipo bit para validación de balance.</log>
</ChangeLog>
*********************************************************************/

BEGIN
	
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


	INSERT INTO @tmpAgentBalanceVal
		SELECT * 
		FROM AgentBalance
		WHERE IdAgent=@IdAgent
			and DateOfMovement>=@DateOfMovement
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

	--select Balance1,IdAgentBalance,IdAgent,TypeOfMovement,DateOfMovement,Amount,Reference,[Description],Country,Commission,DebitOrCredit,Balance,IdTransfer,FxFee,IsMonthly from @TmpAgBalVal


	declare @Balance money
	declare @IdAB1 int
	declare @Num1 int=2


	while (@Num1<=@Max)
	begin
	
		set @Balance=(select Balance from @TmpAgBalVal where id=@Num1)

		if (@Balance != (select Balance1 from @TmpAgBalVal where id=@Num1))
		begin
			set @IdAB1=(select IdAgentBalance from @TmpAgBalVal where id=@Num1)
			--select 'El IdAgent '+CONVERT(varchar,@IdAgent)+' es erróneo en el IdAgentBalance '+convert(varchar,@IdAB1) as Resultado
			set @IsCorrect=0--#2
			Return
		end
		else 
		begin
			delete from @TmpAgBalVal where id=@Num1
		end

		set @Num1=@Num1+1
	end
	
	--select 'Ajuste de balance correcto!'
	set @IsCorrect=1--#2

END

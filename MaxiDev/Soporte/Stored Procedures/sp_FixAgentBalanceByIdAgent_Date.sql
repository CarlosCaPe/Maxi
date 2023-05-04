
CREATE PROCEDURE [Soporte].[sp_FixAgentBalanceByIdAgent_Date]
	@IdAgent INT,
	@DateOfMovement datetime,
	@Correct bit OUTPUT
AS

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que corrige descuadres en balance de agente, según acomodo por fecha.</Description>

<ChangeLog>
<log Date="02/01/2020" Author="jdarellano">Creación.</log>
</ChangeLog>
*********************************************************************/

BEGIN

	set nocount on;

	Begin try
		DECLARE @idagentbalancebase int
	DECLARE @DateMovementagentbalancebase datetime

	IF OBJECT_ID('tempdb..#tmpAgentBalanceVal') IS NOT NULL DROP TABLE #tmpAgentBalanceVal
	CREATE TABLE #tmpAgentBalanceVal  
	(
		id			   int identity (1,1),
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


	INSERT INTO #tmpAgentBalanceVal
		SELECT * 
		FROM dbo.AgentBalance with (nolock)
		WHERE IdAgent=@IdAgent
			and DateOfMovement>=@DateOfMovement
		ORDER BY DateOfMovement

	--Select * From #tmpAgentBalanceVal

	IF OBJECT_ID('tempdb..#TmpAgBalVal') IS NOT NULL DROP TABLE #TmpAgBalVal
	CREATE TABLE #TmpAgBalVal
	(
		Balance1	   money not null,
		id			   int,
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


	declare @Max int=(select MAX(id) from #tmpAgentBalanceVal)
	declare @Ids int=1

	while (@Ids<=@Max)
	begin
		if (@Ids=1)
		begin
			declare @Balance1 money=0.00

			insert into #TmpAgBalVal
				SELECT Balance1=@Balance1,* 
				FROM #tmpAgentBalanceVal ab WHERE IdAgent=@IdAgent and id=@Ids
				ORDER BY DateOfMovement

			set @Ids=@Ids+1
		end

		else
		begin
			insert into #TmpAgBalVal
				SELECT Balance1=(SELECT sum (Amount*CASE WHEN DebitOrCredit='Credit' THEN -1 ELSE 1 END) FROM  #tmpAgentBalanceVal ab2 WHERE ab2.IdAgent =ab.idAgent AND ab2.IdAgentBalance = ab.idAgentBalance)
				                +
					            (select Balance FROM #tmpAgentBalanceVal ab where id=(@Ids-1)) ,* 
				FROM #tmpAgentBalanceVal ab WHERE IdAgent=@IdAgent and id=@Ids
				ORDER BY DateOfMovement

			set @Ids=@Ids+1
		end
	end 

	--select * from #TmpAgBalVal
	
	--select * from #TmpAgBalVal


	declare @Balance money
	declare @Num1 int=2

	while (@Num1<=@Max)
	begin
	
		set @Balance=(select Balance from #TmpAgBalVal where id=@Num1)

		if (@Balance != (select Balance1 from #TmpAgBalVal where id=@Num1))
		begin
			set @idagentbalancebase=(select IdAgentBalance from #TmpAgBalVal where id=(@Num1-1))
			set @DateMovementagentbalancebase = (select DateOfMovement from #TmpAgBalVal where id=(@Num1-1))
			--select @idagentbalancebase as IdAgentBalance
			set @Num1=@Max
		end


		set @Num1=@Num1+1
	end
	
	--Select ErrorBalance = @idagentbalancebase

	if(@idagentbalancebase is null)
	begin
		--Select ErrorBalance = @idagentbalancebase
		return;
	end
	--set @idagentbalancebase=(select IdAgentBalance from #TmpAgBalVal where id=@Max)
	--select @idagentbalancebase as IdAgentBalanceBase
			
/*----------------------------------------------Corregir balance---------------------------------------------------------------------------------------------*/
	--BEGIN TRANSACTION
		IF OBJECT_ID('tempdb..#tmpAgentBalance') IS NOT NULL DROP TABLE #tmpAgentBalance
		select IdAgentBalance,Amount,DebitOrCredit,IdAgent,Balance,DateOfMovement
		into #tmpAgentBalance
		from [dbo].[AgentBalance] with(nolock) 
		where idagent=@idAgent 
		--and IdAgentBalance>=@idagentbalancebase
		and DateOfMovement >= @DateMovementagentbalancebase
		order by DateOfMovement ASC
		
		--Select * from #tmpAgentBalance

		declare @Id int,
			@IdagentBalance int,
			@Amount Money,
			@AmountF Money,
			@DebitOrCredit nvarchar(max)

		IF OBJECT_ID('tempdb..#TmpBalanceData') IS NOT NULL DROP TABLE #TmpBalanceData
		CREATE TABLE #TmpBalanceData
		(
			Id int identity(1,1),
			IdagentBalance int,
			Amount Money, 
			DebitOrCredit nvarchar(max)
		)

		insert into #TmpBalanceData
			select IdagentBalance,amount,DebitOrCredit from #tmpAgentBalance where DateOfMovement > @DateMovementagentbalancebase /*idagentbalance>@idagentbalancebase*/ and idagent=@idAgent order by DateOfMovement--IdAgentBalance--#1
			
		--Select RegistrosaTmpBalanceData = @@ROWCOUNT

		--select * from #tmpAgentBalance where IdAgent = 7121 /*and IdAgentBalance > 39940442*/ order by DateOfMovement
		--select * from #TmpBalanceData

		set @Amount=0
		
		select top 1 @AmountF=balance from #tmpAgentBalance where DateOfMovement >= @DateMovementagentbalancebase /*idagentbalance>=@idagentbalancebase*/  and idagent=@idAgent order by DateOfMovement--IdAgentBalance--#1
		--select @AmountF AmountF

		while exists(select 1 from #TmpBalanceData)
		begin 
			--select top 1 @Id=id,@IdagentBalance=IdagentBalance,@Amount=Amount,@DebitOrCredit=DebitOrCredit from @TmpBalanceData order by id    
			select top 1 @Id=id,@IdagentBalance=IdagentBalance,@AmountF=@AmountF+(CASE (DebitOrCredit) WHEN 'Debit' THEN Amount ELSE -Amount END),@DebitOrCredit=DebitOrCredit from #TmpBalanceData order by id--#1
			/*if @DebitOrCredit='Debit'
				set @AmountF=@AmountF+@Amount
			else
				set @AmountF=@AmountF-@Amount*/
			--if (@idagentbalancebase=)

			update [dbo].[agentbalance] set balance=@AmountF where IdagentBalance=@IdagentBalance
			--select * from [dbo].[agentbalance] with (nolock) where IdAgentBalance=@IdagentBalance
			--select * from #TmpBalanceData where id=@Id
			delete from #TmpBalanceData where id=@Id
		end

		update [dbo].[AgentCurrentBalance] set balance=@AmountF where idagent=@idAgent
		--select * from  [dbo].[AgentCurrentBalance] with (nolock) where idagent=@idAgent
		--DROP TABLE #tmpAgentBalance

		/*-------------------------------------------------Validar balance-------------------------------------------------------------------------------------------------------------------*/

		IF OBJECT_ID('tempdb..#tmpAgentBalanceVal2') IS NOT NULL DROP TABLE #tmpAgentBalanceVal2
		CREATE TABLE #tmpAgentBalanceVal2
		(
			id			   int identity (1,1),
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


		INSERT INTO #tmpAgentBalanceVal2
			SELECT * 
			FROM dbo.AgentBalance with (nolock)
			WHERE IdAgent=@IdAgent
				and DateOfMovement>=@DateOfMovement
			ORDER BY DateOfMovement

		IF OBJECT_ID('tempdb..#TmpAgBalVal2') IS NOT NULL DROP TABLE #TmpAgBalVal2
		CREATE TABLE #TmpAgBalVal2
		(
			Balance1	   money null,
			id			   int,
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


		declare @Max2 int=(select MAX(id) from #tmpAgentBalanceVal2)
		declare @Ids2 int=1

		while (@Ids2<=@Max2)
		begin
			if (@Ids2=1)
			begin
				declare @Balance12 money=0.00

				insert into #TmpAgBalVal2
					SELECT Balance1=@Balance12,* 
					FROM #tmpAgentBalanceVal2 ab WHERE IdAgent=@IdAgent and id=@Ids2
					ORDER BY DateOfMovement

				set @Ids2=@Ids2+1
			end

			else
			begin
				insert into #TmpAgBalVal2
					SELECT Balance1=(SELECT sum (Amount*CASE WHEN DebitOrCredit='Credit' THEN -1 ELSE 1 END) FROM  #tmpAgentBalanceVal2 ab2 WHERE ab2.IdAgent =ab.idAgent AND ab2.IdAgentBalance = ab.idAgentBalance)+
						(select Balance FROM #tmpAgentBalanceVal2 ab where id=(@Ids2-1)) ,* 
					FROM #tmpAgentBalanceVal2 ab WHERE IdAgent=@IdAgent and id=@Ids2
					ORDER BY DateOfMovement

				set @Ids2=@Ids2+1
			end
		end 

	--select * from #TmpAgBalVal2


	declare @Balance2 money
	declare @IdAB12 int
	declare @Num12 int=2


	while (@Num12<=@Max2)
	begin
	
		set @Balance2=(select Balance from #TmpAgBalVal2 where id=@Num12)

		if (@Balance2 != (select Balance1 from #TmpAgBalVal2 where id=@Num12))
		begin
			set @IdAB12=(select IdAgentBalance from #TmpAgBalVal2 where id=@Num12)
				--select 'Ajuste de balance erróneo en IdAgentBalance '+CONVERT(varchar,@IdAB12)+'.'
				set @Correct=0
				--ROLLBACK TRANSACTION
				--Return
			end
			else 
			begin
				delete from #TmpAgBalVal2 where id=@Num12
			end

			set @Num12=@Num12+1
		end
	
	--COMMIT TRANSACTION
	--select 'Ajuste de balance correcto!'
	set @Correct=1

	drop table #tmpAgentBalanceVal
	drop table #TmpAgBalVal
	drop table #tmpAgentBalance
	drop table #TmpBalanceData
	drop table #tmpAgentBalanceVal2
	drop table #TmpAgBalVal2

	End try
	Begin Catch    
	DECLARE @ErrorMessage varchar(max)                                                                 
		Select @ErrorMessage=ERROR_MESSAGE()   
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Soporte.sp_FixAgentBalanceByIdAgent_Date',Getdate(),@ErrorMessage)
	End catch

END
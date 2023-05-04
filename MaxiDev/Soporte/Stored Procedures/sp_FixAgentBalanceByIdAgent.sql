
CREATE PROCEDURE [Soporte].[sp_FixAgentBalanceByIdAgent]
	@IdAgent INT,
	@DateOfMovement datetime
AS

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que corrige descuadres en balance de agente.</Description>

<ChangeLog>
<log Date="24/07/2017" Author="jdarellano">Creación.</log>
<log Date="24/04/2018" Author="jdarellano" Name="#1">Mejora en el proceso de validación y ajuste del balance.</log>
</ChangeLog>
*********************************************************************/

BEGIN

	set nocount on;

	Begin try
		DECLARE @idagentbalancebase int


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
			FROM dbo.AgentBalance with (nolock)
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


		declare @Max int=(select MAX(id) from @tmpAgentBalanceVal)--{#1
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

	

		declare @Balance money
		declare @Num1 int=2

		while (@Num1<=@Max)
		begin
	
			set @Balance=(select Balance from @TmpAgBalVal where id=@Num1)

			if (@Balance != (select Balance1 from @TmpAgBalVal where id=@Num1))
			begin
				set @idagentbalancebase=(select IdAgentBalance from @TmpAgBalVal where id=(@Num1-1))
			

				/*----------------------------------------------Corregir balance---------------------------------------------------------------------------------------------*/
				select IdAgentBalance,Amount,DebitOrCredit,IdAgent,Balance,DateOfMovement
				into #tmpAgentBalance
				from [dbo].[AgentBalance] with(nolock) where idagent=@idAgent and IdAgentBalance>=@idagentbalancebase

				declare @Id int,
					@IdagentBalance int,
					@Amount Money,
					@AmountF Money,
					@DebitOrCredit nvarchar(max)

				declare @TmpBalanceData table
				(
					Id int identity(1,1),
					IdagentBalance int,
					Amount Money, 
					DebitOrCredit nvarchar(max)
				)

				insert into @TmpBalanceData
					select IdagentBalance,amount,DebitOrCredit from #tmpAgentBalance where idagentbalance>@idagentbalancebase and idagent=@idAgent order by DateOfMovement--IdAgentBalance--#1

				set @Amount=0

				select top 1 @AmountF=balance from #tmpAgentBalance where idagentbalance>=@idagentbalancebase  and idagent=@idAgent order by DateOfMovement--IdAgentBalance--#1
		
				while exists(select 1 from @TmpBalanceData)
				begin 
					--select top 1 @Id=id,@IdagentBalance=IdagentBalance,@Amount=Amount,@DebitOrCredit=DebitOrCredit from @TmpBalanceData order by id    
					select top 1 @Id=id,@IdagentBalance=IdagentBalance,@AmountF=@AmountF+(CASE (DebitOrCredit) WHEN 'Debit' THEN Amount ELSE -Amount END),@DebitOrCredit=DebitOrCredit from @TmpBalanceData order by id--#1
					/*if @DebitOrCredit='Debit'
						set @AmountF=@AmountF+@Amount
					else
						set @AmountF=@AmountF-@Amount*/
					--if (@idagentbalancebase=)--}

					update [dbo].[agentbalance] set balance=@AmountF where IdagentBalance=@IdagentBalance

					delete from @TmpBalanceData where id=@Id
				end

				update [dbo].[AgentCurrentBalance] set balance=@AmountF where idagent=@idAgent

				DROP TABLE #tmpAgentBalance
				set @Num1=@Max
					
			end

			set @Num1=@Num1+1
		end
	
		--=====Correo de notificación=====--
		--declare @Body1 varchar(500)
		

		--set @Body1='Ajuste en balance para IdAgent '+convert(varchar,@IdAgent)+' ('+convert(varchar,(select agentcode from dbo.Agent with (nolock) where idagent=@IdAgent))+')'+' ejecutado'


		--EXEC msdb.dbo.sp_send_dbmail @profile_name='Maxi notification email',--Prod
		----EXEC msdb.dbo.sp_send_dbmail @profile_name='Maxiemail',---Solo para Stage
		--@recipients='soportemaxi@boz.mx; jmolina@boz.mx;',
		--@subject='Ajuste balance',
		----@body=@TableHTML,
		--@body = @Body1,
		--@body_format = 'HTML'

	End try
	Begin Catch    
	DECLARE @ErrorMessage varchar(max)                                                                 
		Select @ErrorMessage=ERROR_MESSAGE()   
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Soporte.sp_FixAgentBalanceByIdAgent',Getdate(),@ErrorMessage)
	End catch

END
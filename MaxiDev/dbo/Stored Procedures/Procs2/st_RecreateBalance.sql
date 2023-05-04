CREATE procedure [dbo].[st_RecreateBalance] 
@IdAgent int,
@date datetime
as

set nocount on

Begin Try

       Begin Transaction

	   Delete  AgentOtherCharge where IdAgentBalance in 
		(
		Select IdAgentBalance from ABorrardeBalance where idAgent=@IdAgent
		)


	   Delete AgentBalance where IdAgentBalance in 
		(
		Select IdAgentBalance from ABorrardeBalance where idAgent=@IdAgent
		)

		


       Declare @IdAgentBalancePivote int= (select top 1 IdAgentBalance from AgentBalance where IdAgent=@IdAgent and DateOfMovement< @date order by IdAgentBalance desc)

       declare @tempBalane table 
       (
       id int identity (1,1),
       idAgentBalance int
       )

       insert @tempBalane(idAgentBalance)
       select IdAgentBalance
       from AgentBalance
       where IdAgentBalance>@IdAgentBalancePivote and IdAgent =@IdAgent
       order by IdAgentBalance 

       --Comentar
       --select * from @tempBalane

      
             --select * from AgentBalance where IdAgentBalance=@IdAgentBalancePivote

             declare @LastBalance money=0, @NextBalance money=0
             declare @IdAgentBalanceTemp int, @IdTemp int


             set @LastBalance=(select Balance from AgentBalance where IdAgentBalance =@IdAgentBalancePivote)

			if (exists(select 1 from @tempBalane))
			Begin


				 select top 1 @IdAgentBalanceTemp=idAgentBalance , @IdTemp=Id
				 from @tempBalane 
				 order by Id

				 while(@IdTemp is not null)
				 Begin

						update AgentBalance set Balance=@LastBalance+case when DebitOrCredit='Debit' then Amount else  -1*Amount end,
														  @NextBalance= @LastBalance+case when DebitOrCredit='Debit' then Amount else  -1*Amount end
						where IdAgentBalance =@IdAgentBalanceTemp

						--select IdAgentBalance, @LastBalance LastBalance, DebitOrCredit, Amount,  @LastBalance+case when DebitOrCredit='Debit' then Amount else -1*Amount end NexBalance
						--from AgentBalance 
						--where IdAgentBalance =@IdAgentBalanceTemp

						delete @tempBalane where Id=@IdTemp
       
						set @LastBalance=@NextBalance
						set @IdAgentBalanceTemp= null
						set @IdTemp= null

						select top 1 @IdAgentBalanceTemp=idAgentBalance , @IdTemp=Id
						from @tempBalane 
						order by Id

				 End
			 End
             update [AgentCurrentBalance] set Balance=@LastBalance where IdAgent=@IdAgent
      
      
       Commit
       
End Try
Begin Catch

       print 'ERROR'
       print @IdAgent
	   print  ERROR_MESSAGE()
	   print ERROR_LINE() 
       
       Rollback
       
End catch


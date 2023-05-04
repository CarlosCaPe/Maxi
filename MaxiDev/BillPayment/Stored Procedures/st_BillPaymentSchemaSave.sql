
CREATE PROCEDURE [BillPayment].[st_BillPaymentSchemaSave]
   @IdAgent int
   , @IdAggregator int
	 , @IdFee int 
	    ,@IdBiller int
   , @IdCommission int
	 , @IdStatus int 
	    ,@CommissionSpecial Money = null
   , @DateForCommission datetime = null
	 , @IdUser int 
	 , @HasError int out
	 , @Message nvarchar(max) out


as

/********************************************************************
<Author>Adominguez</Author>
<app>MaxiCorp</app>
<Description>Guarda y/o actualiza la tabla BillerSchemasAgent</Description>

<ChangeLog>

<log Date="18/08/2018" Author="adominguez">Creation</log>
</ChangeLog>

--Exec [BillPayment].[st_BillPaymentSchemaSave] 1240,1,34,3,1,1,0,null,9168,0,''
*********************************************************************/

begin try 
	set @HasError = 0
	set @Message='' 

	declare @IdPreviousFee int
	declare @IdCurrentFee int 
	declare @IdState int
	declare @StateCode varchar(5)
	declare @IdPreviousCommission int,@IdCurrentCommission int
	declare @PreviousTempSpread Money
	declare @PreviousEndDateTempSpread  datetime
	declare @CurrentTempSpread Money
	declare @CurrentEndDateTempSpread datetime

	set @IdCurrentFee = @IdFee
	set @IdCurrentCommission = @IdCommission
	set @CurrentTempSpread = @CommissionSpecial
	set @CurrentEndDateTempSpread =@DateForCommission
	
	 select 
 
 @StateCode = AgentState 
from 
 Agent 
where 
 IdAgent= @idagent
 
select @IdState = idState from State  where StateCode=@StateCode


		
	 if exists(	
						select 
					     1
						from 
						 BillPayment.AgentForBillers  
						where 
				 	   IdBiller 	=@IdBiller
							 and IdAgent = @IdAgent
						)
		 begin 

  
				 set @IdPreviousFee = (Select B.IdFee 
										from BillPayment.AgentForBillers B 
										inner join BillPayment.Billers Bi on Bi.IdBiller = B.IdBiller and Bi.IdAggregator = @IdAggregator 
										where B.IdBiller = @IdBiller 
										and B.IdAgent = @IdAgent )

				 set @IdPreviousCommission = (Select B.IdCommission 
										from BillPayment.AgentForBillers B 
										inner join BillPayment.Billers Bi on Bi.IdBiller = B.IdBiller and Bi.IdAggregator = @IdAggregator 
										where B.IdBiller = @IdBiller 
										and B.IdAgent = @IdAgent )

				set @PreviousTempSpread = (Select B.CommionSpecial 
										from BillPayment.AgentForBillers B 
										inner join BillPayment.Billers Bi on Bi.IdBiller = B.IdBiller and Bi.IdAggregator = @IdAggregator 
										where B.IdBiller = @IdBiller 
										and B.IdAgent = @IdAgent )

				set @PreviousEndDateTempSpread = (Select B.DateForCommision 
										from BillPayment.AgentForBillers B 
										inner join BillPayment.Billers Bi on Bi.IdBiller = B.IdBiller and Bi.IdAggregator = @IdAggregator 
										where B.IdBiller = @IdBiller 
										and B.IdAgent = @IdAgent )
	 
						 update 
							 BillPayment.AgentForBillers 
						 set 
							  --
							  --IdStatus        	= @IdStatus,
							  IdFee =@IdFee,
							  IdCommission = @IdCommission,
							  CommionSpecial = @CommissionSpecial,
							  DateForCommision = @DateForCommission

							where 
							 IdBiller 					= @IdBiller
							 and IdAgent = @IdAgent
				 		 
						 
				
		  end

		else
		begin
			insert into BillPayment.AgentForBillers 
			Select @IdBiller, @IdAgent, @IdFee, @IdCommission, @CommissionSpecial, @DateForCommission, @IdStatus
			--Select 3,1240,39,1,0,null,1
			--print '1'
			set @IdPreviousFee = (Select B.IdFee from BillPayment.StateForBillers B inner join BillPayment.Billers Bi on Bi.IdBiller = B.IdBiller and Bi.IdAggregator = @IdAggregator where B.IdBiller = @IdBiller and B.IdState = @IdState )
			set @IdPreviousCommission = (Select B.IdCommission from BillPayment.StateForBillers B inner join BillPayment.Billers Bi on Bi.IdBiller = B.IdBiller and Bi.IdAggregator = @IdAggregator where B.IdBiller = @IdBiller and B.IdState = @IdState )
			set @PreviousTempSpread =  null
			set @PreviousEndDateTempSpread = null
		end


		IF @IdPreviousFee<>@IdCurrentFee
		BEGIN
		--print '2'
			INSERT AgentSchemaDetailFeeLog (IdAgentSchema, IdPayerConfig, IdPreviousFee, IdCurrentFee, DateOfLastChange, EnterByIdUser, IdAgent)
			VALUES (@IdAggregator, @IdBiller, @IdPreviousFee, @IdCurrentFee, GETDATE(), @IdUser, @IdAgent)
			
		END
		
		IF @IdPreviousCommission<>@IdCurrentCommission
		BEGIN
		--print '3'
			INSERT AgentSchemaDetailCommissionLog (IdAgentSchema, IdPayerConfig, IdPreviousCommission, IdCurrentCommission, DateOfLastChange, EnterByIdUser, IdAgent)
			VALUES (@IdAggregator, @IdBiller, @IdPreviousCommission, @IdCurrentCommission, GETDATE(), @IdUser, @IdAgent)

		END

		If @PreviousEndDateTempSpread<>@CurrentEndDateTempSpread  OR (@PreviousEndDateTempSpread is null and @CurrentEndDateTempSpread is not null)
		BEGIN
			INSERT AgentSchemaDetailTempSpreadLog (IdAgentSchema, IdPayerConfig, PreviousTempSpread, PreviousEndDateTempSpread, CurrentTempSpread, CurrentEndDateTempSpread, DateOfLastChange, EnterByIdUser, IdAgent)
			VALUES (@IdAggregator, @IdBiller, @PreviousTempSpread, @PreviousEndDateTempSpread, @CurrentTempSpread, @CurrentEndDateTempSpread, GETDATE(), @IdUser, @IdAgent)


		END

  --      ---se agrego is null
		--IF isnull(@IdPreviousSpread,0)<>@IdCurrentSpread OR @PreviousSpread<>@CurrentSpread 
		--BEGIN
		--	INSERT AgentSchemaDetailSpreadLog (IdAgentSchema, IdPayerConfig, IdPreviousSpreadValue, PreviousSpreadValue, IdCurrentSpreadValue, CurrentSpreadValue, DateOfLastChange, EnterByIdUser)
		--	VALUES (@IdAgentSchema, @IdPayerConfig, @IdPreviousSpread, @PreviousSpread, @IdCurrentSpread, @CurrentSpread, @Date, @EnterByIdUser)

			
		--END
		  
End Try
Begin Catch 
 set @HasError = 1
 set @Message='Error'
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_BillPaymentSchemaSave',Getdate(),ERROR_MESSAGE())    
End Catch



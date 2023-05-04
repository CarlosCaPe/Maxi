
CREATE PROCEDURE [BillPayment].[st_UpdateBillerClone]
   @IdBiller int
 , @IdBillerOfClone int
 , @IdUser int 
 , @HasError int out
 , @Message nvarchar(max) out

as

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Clonar valores de un Biller a otro</Description>

<ChangeLog>

<log Date="05/07/2018" Author="amoreno">Creation</log>
<log Date="16/05/2019" Author="azavala">Creation</log>
</ChangeLog>
*********************************************************************/
begin try 
	set @HasError = 0
	set @Message='' 
	 
	declare 
	 @BuyRate decimal(18,2)
	 , @CommBiller decimal(18,2)
	 , @IdStatusActivo int 
	 
	 set @IdStatusActivo= 1
		
	 if exists(select 1	from BillPayment.Billers with(nolock) where IdBiller= @IdBillerOfClone)
		 begin
			select
				@BuyRate = B.BuyRate
				, @CommBiller = B.CommBiller
			from 
				BillPayment.Billers  B
			where 
				IdBiller= @IdBillerOfClone
				 
				update 
						BillPayment.Billers 
						set 
						BuyRate 			= @BuyRate
						, CommBiller		= @CommBiller
						, IdBillerOfClone 	= @IdBillerOfClone
						, IdStatus        	= @IdStatusActivo
						where 
						IdBiller = @IdBiller
		 
		 
		 
 /* Inicio de clonar los estados */					 
 select @IdBiller,@IdBillerOfClone
 
	select 
	 p1.idstate
	 , p1.idfee
	 , p1.IdCommission
	 , p1.idstatus 
	 into #temp
	from 
	 BillPayment.StateForBillers p1 with(nolock)
	inner join 
	 BillPayment.StateForBillers p2 with(nolock)
	on 
	 p2.Idstate=p1.Idstate
	 and p2.idbiller=@IdBillerOfClone
	where
	 p1.idbiller= @IdBiller
	
	
	
	
	
	update 
	  BillPayment.StateForBillers
	 set
	  BillPayment.StateForBillers.idFee= #temp.idfee
	  , BillPayment.StateForBillers.IdCommission = #temp.IdCommission
	  , BillPayment.StateForBillers.idstatus= #temp.idstatus
	  from 
	     BillPayment.StateForBillers with(nolock)
	  inner join 
	    #temp
	  on 
	    BillPayment.StateForBillers.idstate= #temp.idstate
	   where 
	     BillPayment.StateForBillers.idbiller= @IdBiller
	
	
	
	
	insert into
	 BillPayment.StateForBillers  
	  ( IdBiller
	   , Idstate
	   , IdFee
	   , IdCommission
	   , idStatus
	  )
	select 
	 @IdBiller
	 , S2.Idstate
	 , S2.IdFee
	 , S2.IdCommission
	 , idStatus
	from  
	 BillPayment.StateForBillers as  S2 with(nolock)
	where 
	 S2.idbiller = @IdBillerOfClone 
	 and S2.idstate not in (select idstate from BillPayment.StateForBillers where idbiller= @IdBiller)	 
 /* Fin de clonar los estados */		

/* Inicio de clonar agencias */					 
		select 
		 p1.IdAgent
		 , p1.idfee
		 , p1.IdCommission
		 , p1.CommionSpecial
		 , p1.DateForCommision
		 , p1.idstatus 
		 into #temp2
		from 
		 BillPayment.AgentForBillers p1 with(nolock)
		inner join 
		 BillPayment.AgentForBillers p2 with(nolock)
		on 
		 p2.IdAgent=p1.IdAgent
		 and p2.idbiller= @IdBillerOfClone
		where
		 p1.idbiller= @IdBiller
		
	 
		
		
		update 
		  BillPayment.AgentForBillers
		 set
		  BillPayment.AgentForBillers.idFee= #temp2.idfee
		  , BillPayment.AgentForBillers.IdCommission = #temp2.IdCommission
		  , BillPayment.AgentForBillers.CommionSpecial = #temp2.CommionSpecial
		  , BillPayment.AgentForBillers.DateForCommision = #temp2.DateForCommision
		  , BillPayment.AgentForBillers.idstatus= #temp2.idstatus
		  from 
		     BillPayment.AgentForBillers with(nolock)
		  inner join 
		    #temp2
		  on 
		    BillPayment.AgentForBillers.IdAgent= #temp2.IdAgent
		   where 
		     BillPayment.AgentForBillers.idbiller= @IdBiller
		
		
		
		
		
			
			insert into
			 BillPayment.AgentForBillers  
			  ( IdBiller
			   , IdAgent
			   , IdFee
			   , IdCommission
			   , CommionSpecial
			   , DateForCommision
			   , idStatus
			  )
			select 
			 @IdBiller
			 , S2.IdAgent
			 , S2.IdFee
			 , S2.IdCommission
			 , S2.CommionSpecial
			 , S2.DateForCommision
			 , idStatus
			from  
			 BillPayment.AgentForBillers as  S2 with(nolock)
			where 
			 S2.idbiller = @IdBillerOfClone 
			 and S2.IdAgent not in (select IdAgent from BillPayment.AgentForBillers where idbiller= @IdBiller)

		 /* Fin de clonar los agencias */		








		 
		 
		 insert into 
			  BillPayment.LogForBillers	
			   ( IdBiller	
			     , IdUser
			     , MovementType
			     , DateLastChangue
			     , Description
			    )
			  Values 
				 ( @IdBiller
				   , @IdUser
				   , 'Update Clone'
				   , Getdate()
				   , 'Clone Biller ID' +' ' +  CAST(@IdBillerOfClone AS nvarchar)

				  )


		 
		 insert into 
			  BillPayment.LogForBillers	
			   ( IdBiller	
			     , IdUser
			     , MovementType
			     , DateLastChangue
			     , Description
			    )
			  Values 
				 ( @IdBiller
				   , @IdUser
				   , 'Update Status'
				   , Getdate()
				   , 'Status change 1'

				  )


				
		  end
		  
End Try
Begin Catch 
 set @HasError = 1
 set @Message='Error'
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateBillerClone',Getdate(),ERROR_MESSAGE())    
End Catch


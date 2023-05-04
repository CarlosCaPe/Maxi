CREATE PROCEDURE [Corp].[st_UpdateAggregatorStatus_BillPayment]
   @IdAggregator int
   , @IdStatus int
	 , @IdUser int 
	 , @HasError int out
	 , @Message nvarchar(max) out


as

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Actualiza el Status del Aggregador</Description>

<ChangeLog>

<log Date="30/07/2018" Author="amoreno">Creation</log>
</ChangeLog>
*********************************************************************/
begin try 
	set @HasError = 0
	set @Message='' 
	
	 
	declare 
	  @IdStatusOriginal int 

		
	 if exists(	
						select 
					     1
						from 
						 BillPayment.Aggregator  
						where 
				 	   IdAggregator= @IdAggregator
						)
		 begin 



            select 
					    @IdStatusOriginal = IdStatus
						from 
						 BillPayment.Aggregator  
						where 
				 	   IdAggregator= @IdAggregator   
				 
	 if (@IdStatusOriginal <>@IdStatus)	  
	   begin 
						 update 
							 BillPayment.Aggregator 
						 set 
							  IdStatus        	= @IdStatus
							where 
							 IdAggregator 					= @IdAggregator
				 		 

       end 
				
		  end
		  
End Try
Begin Catch 
 set @HasError = 1
 set @Message='Error'
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_UpdateAggregatorStatus_BillPayment',Getdate(),ERROR_MESSAGE())    
End Catch


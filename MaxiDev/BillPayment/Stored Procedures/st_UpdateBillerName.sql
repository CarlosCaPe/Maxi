
CREATE PROCEDURE [BillPayment].[st_UpdateBillerName]
   @IdBiller int
   , @Name varchar(250) 
   , @IdUser int
   , @IdAggregator int
   , @HasError int out
   , @Message nvarchar(max) out
as

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Actualizar el nombre del Biller</Description>

<ChangeLog>

<log Date="20/06/2018" Author="amoreno">Creation</log>
</ChangeLog>
*Example*





declare
    @HasError int 
   , @Message nvarchar(max)


execute BillPayment.st_UpdateBillerName 1, 'TXU ENERGY ', 9012,1, @HasError  out, @Message  out

   
select * from BillPayment.Billers where IdBiller=1
select * from   BillPayment.LogForBillers where IdBiller=1	

*********************************************************************/
begin try 
set @HasError = 0
set @Message=''


-- if (@IdAggregator<>2)
--  begin 
		if not exists
		            (
		              select 
									  1
									from 	 
									 BillPayment.Billers with (nolock)								
									where 
									 IdAggregator=@IdAggregator
									 and  Name = @Name 
									 and 	IdBiller<>@IdBiller							 
									)
			begin 
			
				UPDATE  
				 BillPayment.Billers 
				SET 
				 Name = @Name			
				WHERE 
				  IdBiller=@IdBiller	
				   and IdAggregator= @IdAggregator
				  				  
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
				   , 'Update Info'
				   , Getdate()
				   , 'Name change' +' ' + @Name
				  )
			end 
		else 
		 begin 
			 set @HasError = 1
			 set @Message='Name duplicate for the  Aggregator'
		 end  
-- end  
		  
End Try
Begin Catch 
 set @HasError = 1
 set @Message='Error'
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateBillerName',Getdate(), 'Biller = ' + @Name + ', ' + ERROR_MESSAGE())    
End Catch


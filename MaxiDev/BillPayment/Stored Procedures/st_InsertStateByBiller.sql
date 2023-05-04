

CREATE PROCEDURE [BillPayment].[st_InsertStateByBiller]

 @IdBiller int
 , @IdState int
 , @IdStatus int 
 , @IdUser   int 
 , @HasError int out
 , @Message nvarchar(max) out

as


/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Inserta o actualiza los estados por Biller</Description>

<ChangeLog>

<log Date="12/07/2018" Author="amoreno">Creation</log>
<log Date="19/10/2018" Author="amoreno">Se agrega default de Fee y Commision para billers de FE</log>
</ChangeLog>
*********************************************************************/
begin try 
	set @HasError = 0
	set @Message='' 
	
 if exists(
           select  
            1
           from 
            BillPayment.StateForBillers St
           where 
            St.IdBiller= @IdBiller
            and St.IdState = @IdState
         
          )
	   begin 
	    update 
	      BillPayment.StateForBillers
	    set 
	     IdStatus = @IdStatus
	    where  
	     IdBiller = @IdBiller
	     and IdState = @IdState    
	     
	      		 
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
				   , 'Update States'
				   , Getdate()
				   , 'Change Status for State  ID' +' ' +  CAST(@IdState AS nvarchar) + ' Status: ' + CAST(@IdStatus AS nvarchar)
				  )
	      
	      
	   end
 else
   begin 
     if(@IdStatus<>0)
       begin 
       
declare 
 @idFee int
 , @IdCommission int 
 , @idFeeDefualt int
 , @IdCommissionDefualt int 
 , @idaggregator int
 , @Relationship nvarchar(255)

 
 select @idaggregator= idaggregator,  @Relationship = Relationship from BillPayment.Billers with (nolock) where idbiller= @IdBiller

set  @IdCommissionDefualt= 
									(case 
									   when 
									     @idaggregator=1 and @Relationship='Non Contracted'
									   then 
									    56
									   when 
									      @idaggregator=1 and @Relationship='Authorized'
									    then 
									     57
									  else
									   0
									  end
                  )
                  
set  @idFeeDefualt= 
									(case 
									   when 
									     @idaggregator=1 and @Relationship='Non Contracted'
									   then 
									    12
									   when 
									      @idaggregator=1 and @Relationship='Authorized'
									    then 
									     1
									  else
									   0
									  end
                  )
                  
                  

  set  @idFee = isnull((select idfee from  BillPayment.StateForBillers with (nolock)  where idbiller= @IdBiller  and IdStateBiller= (select max(IdStateBiller) from BillPayment.StateForBillers where idbiller=@IdBiller )),@idFeeDefualt)       
  
  set  @IdCommission =  isnull((select IdCommission from  BillPayment.StateForBillers  with (nolock)  where idbiller= @IdBiller  and IdStateBiller= (select max(IdStateBiller) from BillPayment.StateForBillers where idbiller=@IdBiller )) ,@IdCommissionDefualt) 
         
          insert into 
            BillPayment.StateForBillers
             (
             	IdBiller       
              , IdState 
              , IdFee
              , IdCommission  
              , IdStatus
             )
             Values 
				     (
				       @IdBiller
				      , @IdState
				      , @idFee
				      , @IdCommission
				      , @IdStatus
				     )
				     
				     
				     	      		 
		 insert into 
			  BillPayment.LogForBillers	
			   ( IdBiller	
			     , IdUser
			     , DateLastChangue
			     , Description
			    )
			  Values 
				 ( @IdBiller
				   , @IdUser
				   , Getdate()
				   , 'Insert State  ID' +' ' +  CAST(@IdState AS nvarchar)+ ' by Biller'  + ' Status: ' + CAST(@IdStatus AS nvarchar)
				  )
				     
				     
       end            
   end 
end Try
Begin Catch 
 set @HasError = 1
 set @Message='Error'
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_InsertStateByBiller',Getdate(),ERROR_MESSAGE())    
End Catch


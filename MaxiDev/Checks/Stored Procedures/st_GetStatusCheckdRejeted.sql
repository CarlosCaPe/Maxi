
	
	CREATE PROCEDURE [Checks].[st_GetStatusCheckdRejeted]
	  @IdBank int
	  , @CheckNumber 		nvarchar(50)
	  , @RoutingNumber 	nvarchar(50)
	  , @Account        nvarchar(50)
	  , @Amount         money =null
	  
	AS
/********************************************************************
<Author>Amoreno</Author>
<app>MaxiAgente</app>
<Description>Optener razon de rechazo de Cheques en realcion de bancos con Maxi</Description>

<ChangeLog>

<log Date="30/05/2018" Author="amoreno">Creation</log>
</ChangeLog>
*********************************************************************/
	
	BEGIN
	
	declare 
	 @NumChecks int 
	 
	  select 
	   @NumChecks= count(1)		 
    from 
     dbo.Checks  C with (nolock)
    where 
     C.IdCheckProcessorBank = @IdBank
     and C.CheckNumber 	   	= @CheckNumber 
	   and C.RoutingNumber 		= @RoutingNumber 
	   and C.Account 			 		= @Account
	
 if (@NumChecks>1) 
 begin 
   return
 end 
 else
 begin 
  select top 1
			 C.IdCheck
			 , C.IdStatus
			 , C.IdAgent
			 , NameAgent =(select A.AgentCode from dbo.Agent A with (nolock) where A.IdAgent= C.IdAgent)	+' ' + (select A.AgentName from dbo.Agent A with (nolock) where A.IdAgent= C.IdAgent)	
			 , Note  = (  select 
			  							Note 
			  					  from 
			  					   [CheckDetails] with(nolock)
			  					  where 
			  					   IdCheck=  C.IdCheck 
			  					   and  IdCheckDetail = 
			  					                       (select 
			  					                          Max(IdCheckDetail) 
			  					                        from 
			  					                         [CheckDetails] with(nolock)
			  					                        where 
			  					                         IdCheck=  C.IdCheck
			  					                       ) 
		            )
    from 
     dbo.Checks  C with (nolock)
    where 
     C.IdCheckProcessorBank = @IdBank
     and try_convert(bigint,C.CheckNumber)  	  = try_convert(bigint, @CheckNumber) 
	   and try_convert(bigint,C.RoutingNumber) 		= try_convert(bigint,@RoutingNumber )
	   and try_convert(bigint,C.Account) 			 		= try_convert(bigint,@Account)
	   and try_convert(money,C.Amount  ) 			    = try_convert(money,@Amount)  
 end			
	END
	

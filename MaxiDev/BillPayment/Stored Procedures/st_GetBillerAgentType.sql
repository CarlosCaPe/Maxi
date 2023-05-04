
create procedure [BillPayment].[st_GetBillerAgentType] 
   @Idagent int --4636

as


/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Optener Biller By </Description>

<ChangeLog>

<log Date="15/06/2018" Author="amoreno">Creation</log>
</ChangeLog>
*********************************************************************/
 declare 
  @AgentState varchar (5)
  , @idState int 
  , @IsNational bit
  , @IsInternational bit

	
	 set @idState =
	              (select 
	               IdState  
	              from 
	               State
	               where 
	                StateCode =
	                           (
	 															select 
								                 AgentState 
								                from 
								                 Agent 
								                where 
								                 IdAgent = @Idagent
	                           )
	               
	               )	
	               
	                                    	               	 
		select  
  	@IsNational = count(1)
		from 
		 BillPayment.Billers B with (nolock)
		inner join 
		  BillPayment.StateForBillers S with (nolock)
		on 
		 S.Idbiller= B.IdBiller
		 and S.IdState = @idState
		 and S.Idstatus= 1
		 and B.IsDomestic=1 
		inner join 
		 BillPayment.Aggregator A
		on 
		 A.Idstatus= 1
		 and A.IdAggregator = B.IdAggregator

	select  
  @IsInternational=  count(1)
	from 
	 BillPayment.Billers B with (nolock)
	 	inner join 
		 BillPayment.Aggregator A
		on 
		 A.Idstatus= 1
		 and A.IdAggregator = B.IdAggregator
 where  
  B.IdStatus = 1
  and B.IsDomestic= 0

  
  	
  	select @IsInternational AS isInternationalAgent, @IsNational as isNationalAgent
  	 
--select * from  BillPayment.Aggregator where idstatus=1
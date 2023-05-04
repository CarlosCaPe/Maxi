
CREATE procedure [BillPayment].[st_GetResponseCodes] 
   @IdAggregator int
   , @TypeMovent varchar(255)
   , @Lenguaje int =null

as


/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Optener idStatus dependiendo de los responses codes de lso aggregators </Description>

<ChangeLog>


<log Date="22/08/2018" Author="amoreno">Creation</log>
<log Date="22/02/2019" Author="amoreno">Se agrega MessageEsp</log>
</ChangeLog>

execute BillPayment.st_GetResponseCodes 1
*********************************************************************/

	
	select 
	 R.IdAggregator
	 , R.ReturnCode
	 , [Message] = case 
	              when  @Lenguaje = 1
	                then R.[Message]  
	              else
	               R.MessageEsp  
	             end
	 , R.IdStatusMaxi
	from 
   BillPayment.ResPonseCodesAggregator as R with (nolock)	
  where 
   R.IdAggregator= @IdAggregator
   and R.TypeMovent= @TypeMovent

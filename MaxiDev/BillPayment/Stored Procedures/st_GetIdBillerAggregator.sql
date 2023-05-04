
CREATE procedure [BillPayment].[st_GetIdBillerAggregator] 
   @Idbiller int

as


/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Optener IdBiller Aggregator</Description>

<ChangeLog>

<log Date="30/08/2018" Author="amoreno">Creation</log>
<log Date="31/01/2019" Author="azavala">Se agrega la ChoiseData al resultado de la consulta</log>
</ChangeLog>
********************************************************************/
begin
    select  
	   B.idBillerAggregator
	   , B.IdAggregator
	   , B.ChoiseData as BillChoiseData
    from 
	   BillPayment.Billers B with (nolock)
    where  
	   B.idBiller = @Idbiller;
  end 	 

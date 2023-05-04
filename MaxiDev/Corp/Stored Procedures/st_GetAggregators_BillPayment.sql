CREATE PROCEDURE [Corp].[st_GetAggregators_BillPayment]

as

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Optener Agregators</Description>

<ChangeLog>

<log Date="15/06/2018" Author="amoreno">Creation</log>
</ChangeLog>
*********************************************************************/

  select 
   A.IdAggregator
   , A.Name
   , A.Description
  -- , A.IsNational
   , A.IdStatus
  from 
   BillPayment.Aggregator A with (nolock)
  
  

CREATE PROCEDURE [Corp].[st_GetStateByBiller_BillPayment] 
   @IdBiller int
 , @IdCountry int
as

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Obtiene los estados asigandos por Biller</Description>

<ChangeLog>

<log Date="10/07/2018" Author="amoreno">Creation</log>
</ChangeLog>
*********************************************************************/

   select 
    S.IdState
    , S.statename
    , statecode = isnull(S.statecode, '')     
    , IdStatus = isnull(B.IdStatus ,0)	
   from 
    state S WITH (NOLOCK)
   left join 
    BillPayment.StateForBillers B WITH (NOLOCK)
   on 
    B.IdState = S.IdState 
    and B.IdBiller = @IdBiller   
   where idcountry=@Idcountry 
   order by statename



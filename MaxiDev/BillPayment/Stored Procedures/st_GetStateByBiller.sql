
CREATE PROCEDURE [BillPayment].[st_GetStateByBiller] 
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
    state S
   left join 
    BillPayment.StateForBillers B
   on 
    B.IdState = S.IdState 
    and B.IdBiller = @IdBiller   
   where idcountry=@Idcountry 
   order by statename


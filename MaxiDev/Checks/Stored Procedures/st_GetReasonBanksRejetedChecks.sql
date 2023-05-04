
CREATE PROCEDURE [Checks].[st_GetReasonBanksRejetedChecks]

 @idBank int
as

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiAgente</app>
<Description>Optener razon de rechazo de Cheques en realcion de bancos con Maxi</Description>

<ChangeLog>

<log Date="30/05/2018" Author="amoreno">Creation</log>
</ChangeLog>
*********************************************************************/

 select  
  IdReason 
  , MaxiReason
  , BankReason 
 from 
   CheckConfig.ReasonBanksRejetedChecks with (nolock)
 where 
   idBank= @idBank

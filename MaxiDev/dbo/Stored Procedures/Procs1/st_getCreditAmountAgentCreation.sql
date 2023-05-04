
create procedure [dbo].[st_getCreditAmountAgentCreation]

as
/********************************************************************
<Author>Amoreno</Author>
<app>MaxiAgente</app>
<Description>CreditAmount</Description>

<ChangeLog>

<log Date="15/05/2018" Author="amoreno">Creation</log>
</ChangeLog>
*********************************************************************/

 select  top 1 
  CreditAmount 
 from 
  DefaultValuesFromAgentAppToAgent with (nolock)




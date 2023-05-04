/********************************************************************
<Author>  </Author>
<app>Corporativo</app>
<Description> Obtiene el historico de los cambios en los limites de credito para el requerimiento se agrego la columna Note  </Description>

<ChangeLog>
<log Date="07/09/2018" Author="jresendiz">Creacion</log>
</ChangeLog>
*********************************************************************/
CREATE procedure [dbo].[st_GetAgentCreditLimitHistory]
(
    @IdAgent int
)
as
select  top 50 h.CreditAmount,h.DateOfLastChange,h.EnterByIdUser, UserName, h.NoteCreditAmountChange as 'Note'
  from [AgentCreditLimitHistory] h WITH(NOLOCK)
 inner join users u WITH(NOLOCK) on h.EnterByIdUser=u.iduser
 where 1 = 1
   and idagent=@IdAgent 
 order by DateOfLastChange desc






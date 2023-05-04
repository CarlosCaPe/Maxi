CREATE procedure [dbo].[st_GetAgentPromotion]
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

declare @dateActual datetime;

select @dateActual=[dbo].[RemoveTimeFromDatetime](getdate());

select Promotionname,fileguid,extension from [AgentPromotion] with(nolock) where @dateActual>=begindate and @dateActual<=enddate and idgenericstatus=1
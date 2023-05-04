CREATE procedure [dbo].[st_ReportUserSendTransaction]
(
    @StartDate datetime,
    @EndDate datetime,
    @MultiAgent bit
)
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


Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)                
Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate) 

Select UserName,SUM(Total) as Total
From 
(
      select U.UserName,case (ISNull(Au.IdUser,0)) when 0 then 1 else 0 end MultiAgent, COUNT(T.IDTRANSFER) as Total 
      from 
        Users U with(nolock)
      join 
        [Transfer] T with(nolock) on U.IdUser = T.EnterByIdUser             
      left join AgentUser AU with(nolock) on AU.IdUser=U.IdUser
      where T.DateOfTransfer >= @StartDate
      and T.DateOfTransfer < @EndDate     
      AND NOT T.IdStatus = '31'       
      group by U.UserName,case (ISNull(Au.IdUser,0)) when 0 then 1 else 0 end
 
      Union all

      select U.UserName,case (ISNull(Au.IdUser,0)) when 0 then 1 else 0 end MultiAgent, COUNT(T.IdTransferClosed) as Total 
      from 
        Users U with(nolock)
      join 
        TransferClosed T with(nolock) on U.IdUser = T.EnterByIdUser             
      left join AgentUser AU with(nolock) on AU.IdUser=U.IdUser
      where T.DateOfTransfer >= @StartDate
      and T.DateOfTransfer < @EndDate     
      AND NOT T.IdStatus = '31'       
      group by U.UserName,case (ISNull(Au.IdUser,0)) when 0 then 1 else 0 end
 
) m
where m.MultiAgent=case (@MultiAgent) when 1 then 1 else m.MultiAgent end
group by UserName
order by Total desc
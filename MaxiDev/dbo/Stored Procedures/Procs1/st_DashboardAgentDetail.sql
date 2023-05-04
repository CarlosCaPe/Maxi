CREATE Procedure [dbo].[st_DashboardAgentDetail]      
(      
@AgentCode nvarchar(max)      
)      
as      
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Declare @AgentId int,@DateOfTransfer DateTime      
Select @AgentId=IdAgent From Agent with(nolock) where AgentCode=@AgentCode      
      
Set @DateOfTransfer='01/01/1900'       
      
Select  DateOfTransfer  into #temp from [Transfer] with(nolock)       
where IdAgent=@AgentId      
Union      
Select  DateOfTransfer  from  TransferClosed with(nolock)      
where IdAgent=@AgentId       
      
Select top 1 @DateOfTransfer=DateOfTransfer from #temp order by  DateOfTransfer desc      
      
        
Select AgentCode,AgentName,AgentAddress,AgentCity,AgentState,AgentZipcode,AgentPhone,AgentFax,o.Name OwnerName,o.LastName OwnerLastName,o.Phone OwnerPhone, o.cel  OwnerCellPhone,     
isnull((Select top 1 Amount  from AgentDeposit with(nolock) where IdAgent=A.IdAgent order by IdAgentDeposit desc ),0) as LastDeposit,      
isNull((Select top 1 DateOfLastChange  from AgentDeposit with(nolock) where IdAgent=A.IdAgent order by IdAgentDeposit desc ),'') as DateOfLastDeposit,      
@DateOfTransfer as DateOfLastTransaction,B.AgentStatus,A.Notes, ISNULL( Ac.Balance,0) as Balance
From Agent A  with(nolock)     
Join AgentStatus B with(nolock) on (A.IdAgentStatus=B.IdAgentStatus)  
left join AgentCurrentBalance AC with(nolock) on AC.IdAgent = A.IdAgent    
left join [owner] o with(nolock) on a.idowner=o.idowner
Where A.IdAgent=@AgentId
Create PROCEDURE [Corp].[st_DashboardAgentDetail]    
(      
@AgentCode nvarchar(max)      
)      
as      
Set nocount on       
Declare @AgentId int,@DateOfTransfer DateTime      
Select @AgentId=IdAgent From Agent WITH (NOLOCK) where AgentCode=@AgentCode      
      
Set @DateOfTransfer='01/01/1900'       
      
Select  DateOfTransfer  into #temp from Transfer WITH (NOLOCK)
where IdAgent=@AgentId      
Union      
Select  DateOfTransfer  from  TransferClosed WITH (NOLOCK)
where IdAgent=@AgentId       
      
Select top 1 @DateOfTransfer=DateOfTransfer from #temp order by  DateOfTransfer desc      
      
        
Select AgentCode,AgentName,AgentAddress,AgentCity,AgentState,AgentZipcode,AgentPhone,AgentFax,o.Name OwnerName,o.LastName OwnerLastName,o.Phone OwnerPhone, o.cel  OwnerCellPhone,     
isnull((Select top 1 Amount  from AgentDeposit WITH (NOLOCK) where IdAgent=A.IdAgent order by IdAgentDeposit desc ),0) as LastDeposit,      
isNull((Select top 1 DateOfLastChange from AgentDeposit WITH (NOLOCK) where IdAgent=A.IdAgent order by IdAgentDeposit desc ),'') as DateOfLastDeposit,      
@DateOfTransfer as DateOfLastTransaction,B.AgentStatus,A.Notes, ISNULL( Ac.Balance,0) as Balance
From Agent A WITH (NOLOCK)
Join AgentStatus B WITH (NOLOCK) on (A.IdAgentStatus=B.IdAgentStatus)
left join AgentCurrentBalance AC WITH (NOLOCK) on AC.IdAgent = A.IdAgent    
left join owner o WITH (NOLOCK) on a.idowner=o.idowner
Where A.IdAgent=@AgentId

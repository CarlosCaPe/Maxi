CREATE procedure [Corp].[st_ReportAgentsTerminated]      
(      
@Year int,       
@Quarter int      
)      
as      
      
Declare @Month int  
      
Select      
@Month= Case when @Quarter=1 Then 3      
  when @Quarter=2 Then 6      
  when @Quarter=3 Then 9     
  when @Quarter=4 Then 12        
  End      
     
Declare @FechaInicio datetime, @FechaFin datetime      
Select @FechaInicio=Convert(varchar,@Year)+'/'+Convert(varchar,@Month)+'/'+'01'      
Set @FechaFin=DATEADD(month,1,@FechaInicio)           
     
--Select  @FechaInicio,@FechaFin    

Declare @FechaInicioINIT datetime, @FechaFinINIT datetime      
Select @FechaInicioINIT=DATEADD(month,-3,@FechaInicio)   
Set @FechaFinINIT=DATEADD(month,-2,@FechaInicio)           

-- Select  @FechaInicioINIT,@FechaFinINIT       

Select AgentCode as code,
AgentName as Name,
'' as ReasonForClosure,
AgentAddress as Address,
AgentCity as City,
AgentState as State,
AgentZipcode as Zipcode,
AgentPhone as Phone,
o.Name+' '+o.LastName as Owner
from Agent a
left join owner o on o.idowner=a.idowner
where IdAgent not in 
(
Select IdAgent from Transfer where DateOfTransfer>=@FechaInicio and DateOfTransfer<@FechaFin Union
Select IdAgent from TransferClosed where DateOfTransfer>=@FechaInicio and DateOfTransfer<@FechaFin 
) 
And IdAgent in 
(
Select IdAgent from Transfer where DateOfTransfer>@FechaInicioINIT and DateOfTransfer<@FechaFinINIT Union
Select IdAgent from TransferClosed where DateOfTransfer>@FechaInicioINIT and DateOfTransfer<@FechaFinINIT 
) 
order by AgentCode

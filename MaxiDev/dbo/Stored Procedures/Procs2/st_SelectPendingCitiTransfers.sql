CREATE Procedure [dbo].[st_SelectPendingCitiTransfers]            
(            
@StartDate Datetime Output,            
@EndDate Datetime Output            
)            
as            
Set nocount on             
Select top 1  @StartDate=DateOfTransfer from Transfer where IdGateway=11 and IdStatus in (26,23,29,35,40) order by DateOfTransfer asc            
Select top 1  @EndDate=DateOfTransfer from Transfer where IdGateway=11 and IdStatus in (26,23,29,35,40) order by DateOfTransfer desc          
          
Select ClaimCode from Transfer where IdGateway=11 and IdStatus in (26,23,29,35,40)   

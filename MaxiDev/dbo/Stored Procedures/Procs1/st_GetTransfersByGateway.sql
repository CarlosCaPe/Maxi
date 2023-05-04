CREATE procedure [dbo].[st_GetTransfersByGateway]
(
	@idGateway int,
	@StartDate datetime,
	@EndDate datetime		
)
as
SET NOCOUNT ON


set  @EndDate=@EndDate+1
select 
DateOfTransfer as 'Transaction Date',
ClaimCode as 'Claim Code',
AmountInDollars as 'Amount USD',
AmountInMN as 'Amount MN',
(Select top 1 DateofMovement from TransferDetail td with(nolock) where td.IdTransfer = t.IdTransfer and td.IdStatus = 40 order by td.IdTransferDetail desc) as 'Transfer Accepted',
(Select top 1 DateofMovement from TransferDetail td with(nolock) where td.IdTransfer = t.IdTransfer and td.IdStatus = 23 order by td.IdTransferDetail desc) as 'Payment Ready',
(Select top 1 DateofMovement from TransferDetail td with(nolock) where td.IdTransfer = t.IdTransfer and td.IdStatus  in (22,31) order by td.IdTransferDetail desc) as 'Cancelled/Rejected',
(Select top 1 DateofMovement from TransferDetail td with(nolock) where td.IdTransfer = t.IdTransfer and td.IdStatus = 30 order by td.IdTransferDetail desc) as Paid
from Transfer t with(nolock)
where t.DateOfTransfer >= @StartDate and  t.DateOfTransfer< @EndDate
and t.IdGateway =@idGateway

union 

select 
DateOfTransfer as 'Transaction Date',
ClaimCode as 'Claim Code',
AmountInDollars as 'Amount USD',
AmountInMN as 'Amount MN',
(Select top 1 DateofMovement from TransferClosedDetail td with(nolock) where td.IdTransferClosed = t.IdTransferClosed and td.IdStatus = 40 order by td.IdTransferClosedDetail desc ) as 'Transfer Accepted',
(Select top 1 DateofMovement from TransferClosedDetail td with(nolock) where td.IdTransferClosed = t.IdTransferClosed and td.IdStatus = 23 order by td.IdTransferClosedDetail desc) as 'Payment Ready',
(Select top 1 DateofMovement from TransferClosedDetail td with(nolock) where td.IdTransferClosed = t.IdTransferClosed and td.IdStatus  in (22,31) order by td.IdTransferClosedDetail desc) as 'Cancelled/Rejected',
(Select top 1 DateofMovement from TransferClosedDetail td with(nolock) where td.IdTransferClosed = t.IdTransferClosed and td.IdStatus = 30 order by td.IdTransferClosedDetail desc) as Paid
from TransferClosed t with(nolock)
where  t.DateOfTransfer >= @StartDate and  t.DateOfTransfer< @EndDate
and t.IdGateway =@idGateway
Order by DateOfTransfer
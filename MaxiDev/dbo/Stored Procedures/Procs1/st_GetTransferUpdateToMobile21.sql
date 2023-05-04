create procedure [dbo].[st_GetTransferUpdateToMobile21]
as
DECLARE @GatewayId INT = 31 /*TransferToMobile*/
--select 
--    ClaimCode,'' UniqueReferenceNumber
--from 
--    Transfer t
--where 
--t.IdGateway=@GatewayId and t.IdStatus in (21)

declare @datefrom datetime
declare @dateto datetime = getdate()

select @datefrom = min(DateOfTransfer)
from 
    Transfer t
where 
t.IdGateway=@GatewayId and t.IdStatus in (21)

set @datefrom= isnull(@datefrom,@dateto)

select @datefrom dateFrom,@dateto dateTo
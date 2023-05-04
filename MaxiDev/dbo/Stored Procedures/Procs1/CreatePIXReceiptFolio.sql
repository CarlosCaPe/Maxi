CREATE procedure [dbo].[CreatePIXReceiptFolio]
--EXEC [dbo].[CreatePIXReceiptFolio]''
(
	@ClaimCode varchar(16) output
)
as
Declare @urn varchar(16)

--SELECT  FLOOR(RAND()*(999-1)+1)
--Set @urn = right('000000000000'+ FLOOR(RAND()*(999999999999-1)+1), 12)
Set @urn = 'PX01' +right('000000000000'+ Convert(varchar(12),TRY_CAST(FLOOR(RAND()*(999999999999-1)+1) AS BIGINT)), 12)

set @ClaimCode =  @urn 

Select  @ClaimCode








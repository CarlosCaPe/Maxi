CREATE procedure [dbo].[CreateBankayaFolio]--  '',''
--CreateBankayaFolio '',''
(
	@ClaimCode nvarchar(max)  out
)
as
Declare @Prefix nvarchar(max)
Declare @urn nvarchar(max)
Declare @Sequence int

select @Prefix = value from ServiceAttributes where code='BANKAYA' and AttributeKey='Prefix'

update ServiceAttributes set value=convert(int,value)+1,@Sequence=convert(int,value)+1 where code='BANKAYA' and AttributeKey='Sequence'

Set @urn = @Prefix+right('0000000'+ convert(nvarchar,@Sequence), 8)

--select @FolioResult = dbo.GlobalPaycheckDigit(@urn)

set @ClaimCode = @urn --+ convert(nvarchar,@FolioResult)





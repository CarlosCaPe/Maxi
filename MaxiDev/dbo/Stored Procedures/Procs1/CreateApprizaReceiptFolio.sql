create procedure CreateApprizaReceiptFolio
(
	@ClaimCode nvarchar(max) output,
	@FolioResult int output
)
as
Declare @Prefix nvarchar(max)
Declare @urn nvarchar(max)
Declare @Sequence int

select @Prefix=value from ServiceAttributes where code='APPRIZA' and AttributeKey='Prefix'

update ServiceAttributes set value=convert(int,value)+1,@Sequence=convert(int,value)+1 where code='APPRIZA' and AttributeKey='Sequence'

Set @urn = @Prefix+right('0000000'+ convert(nvarchar,@Sequence), 7)

select @FolioResult =dbo.ApprizacheckDigit(@urn)

set @ClaimCode = @urn + convert(nvarchar,@FolioResult)
create procedure CreateGpReceiptFolio
(
	@ClaimCode nvarchar(max) output,
	@FolioResult nvarchar(20) output
)
as
Declare @Prefix nvarchar(max)
Declare @urn nvarchar(max)
Declare @Sequence int

select @Prefix=value from ServiceAttributes where code='GP' and AttributeKey='Prefix'

select @Prefix

update ServiceAttributes set value=convert(int,value)+1,@Sequence=convert(int,value)+1 where code='GP' and AttributeKey='Sequence'

Set @urn = @Prefix+right('0000000'+ convert(nvarchar,@Sequence), 7)

select @FolioResult = dbo.GlobalPaycheckDigit(@urn)

set @ClaimCode = @urn + convert(nvarchar,@FolioResult)


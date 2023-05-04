CREATE procedure [dbo].[CreateEasyPagosFolio]--  '',''
--CreateJetPeruFolio '',''
(
	@ClaimCode nvarchar(max)  out
)
as
Declare @Prefix nvarchar(max)
Declare @urn nvarchar(max)
Declare @Sequence int

select @Prefix = value from ServiceAttributes with(nolock) where code='EP' and AttributeKey='Prefix'

update ServiceAttributes set value=convert(int,value)+1,@Sequence=convert(int,value)+1 where code='EP' and AttributeKey='Sequence'

Set @urn = @Prefix+right('0000000'+ convert(nvarchar,@Sequence), 8)

--select @FolioResult = dbo.GlobalPaycheckDigit(@urn)

set @ClaimCode = @urn --+ convert(nvarchar,@FolioResult)





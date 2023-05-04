create procedure [dbo].[st_GetSerialttapi]
as
declare @serial int

update ServiceAttributes set value=value+1, @serial=value+1  where code='TTAPI' and AttributeKey='Serial'

select @serial serial
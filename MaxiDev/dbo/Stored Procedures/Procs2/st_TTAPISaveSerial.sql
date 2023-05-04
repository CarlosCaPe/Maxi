create procedure [dbo].[st_TTAPISaveSerial]
(
	@Idtransfer Int,
	@Serial Int
)
as

if not exists(select top 1 1 from [TTApiSerial] where Idtransfer=@Idtransfer)
begin 
	insert into [TTApiSerial] values
	(@Idtransfer,@Serial)
end
else
begin
	update [TTApiSerial] set Serial=@Serial where Idtransfer=@Idtransfer
end
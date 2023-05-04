create procedure [Lunex].st_ValidateKey
(
    @Key bigint,
    @IsValid Bit out
)
as
if exists(select top 1 1 from Lunex.TransferLN where [key]=@Key)
begin
    set @IsValid = 0
end
else
begin
    set @IsValid = 1
end

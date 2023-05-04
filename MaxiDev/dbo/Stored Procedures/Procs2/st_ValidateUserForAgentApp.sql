create procedure [dbo].[st_ValidateUserForAgentApp]
(
    @IdUser int,
    @Pass nvarchar(max),
    @IsValid Bit out
)
as

if exists (SELECT top 1 1 from users where [dbo].[fnCreatePasswordHash] (@Pass,salt)=userpassword and iduser=@IdUser)
begin
    set @IsValid=1
end
else
begin
    set @IsValid=0
end
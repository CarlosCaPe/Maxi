CREATE procedure st_UserValidateSellerSession
(
    @IdUserSeller int,
    @DeviceId nvarchar(max)
)
as
select top 1 1 IsValid from seller where IdUserSeller = @IdUserSeller and DeviceId=@DeviceId



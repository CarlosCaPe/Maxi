CREATE procedure [dbo].[st_SellerLogin]
(
    @UserName nvarchar(max),
    @UserPassword nvarchar(max),
    @DevideId nvarchar(max),
    @ForceSession bit,
    @IdLenguage bit,
    @ExistsSessionaActive bit out,
    @IdUserOut int out,
    @HasError bit out,                                                                                            
    @Message varchar(max) out
)
as

BEGIN TRY

Declare @TimeToRegisterLasActivity int
Declare @dateNow datetime

set @ExistsSessionaActive=0
set @IdUserOut=0

select @IdUserOut=iduser from users where userlogin=@UserName and userpassword=@UserPassword

if isnull(@IdUserOut,0)=0
begin
    set @HasError=1
    set @Message='Couldn''t find user'
    return
end

if (@ForceSession=0)
begin
    set @dateNow=getdate()
    select @TimeToRegisterLasActivity=value from GlobalAttributes where name='TimeToRegisterLasActivity'
    
    if exists(select top 1 1  from seller where iduserseller=@IdUserOut and DeviceId!=@DevideId and  DATEDIFF(minute, DateOfLastAccess, @dateNow)<=@TimeToRegisterLasActivity)
    begin
        set @ExistsSessionaActive=1
        set @HasError=1
        set @Message='Someone else might be using the application at this moment, the other user will log off automatically. Are you sure you want to log into the system?'
        return
    end
end

update seller set DateOfLastAccess=getdate(),deviceid= @DevideId where iduserseller=@IdUserOut

INSERT INTO [dbo].[SellerSessionLog]
           ([IdUserSeller]
           ,[DeviceId]
           ,[DateOfCreation])
     VALUES
           (@IdUserOut
           ,@DevideId
           ,getdate())


set @HasError=0
set @Message=''

END TRY
BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @Message = 'Couldn''t find user'
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SellerLogin',Getdate(),@ErrorMessage)    
END CATCH
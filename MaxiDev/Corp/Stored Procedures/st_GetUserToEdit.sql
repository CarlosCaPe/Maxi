CREATE procedure [Corp].[st_GetUserToEdit]
@IdUser int
AS  
Set nocount on;
Begin try
Declare @IdType int = (Select IdUserType from users with (nolock) where iduser= @IdUser)

if @IdType = 1
Select 
u.IdUser, u.IdUserType, [Name], UserLogin, UserName, FirstName, LastName, SecondLastName, AllowToRegisterPc, ChangePasswordAtNextLogin, 
GenericStatus, u.IdGenericStatus, [Address], Cellular, City, ISNULL(co.IdCounty , 0) as IdCounty, ISNULL(CountyName, '') as CountyName,
Email, Phone, [State], ZipCode
from Users u with (nolock)
left join Corporate co with (nolock) on u.IdUser = co.IdUserCorporate
left join County c with (nolock) on co.IdCounty = c.IdCounty
left join GenericStatus gs with (nolock) on u.IdGenericStatus = gs.IdGenericStatus
left join UsersType ut with (nolock) on u.IdUserType = ut.IdUserType
where u.IdUser = @IdUser

else if @IdType = 2
Select au.IdAgent, AgentCode, AgentState, AgentCity, AgentAddress, AgentZipcode, AgentName, u.IdUser, u.IdUserType, [Name], 
UserLogin, UserName, FirstName, LastName, SecondLastName, AllowToRegisterPc, ChangePasswordAtNextLogin, GenericStatus, u.IdGenericStatus
from Users u with (nolock)
left join AgentUser au with (nolock) on u.IdUser = au.IdUser
left join Agent a with (nolock) on au.IdAgent = a.IdAgent
left join GenericStatus gs with (nolock) on u.IdGenericStatus = gs.IdGenericStatus
left join UsersType ut with (nolock) on u.IdUserType = ut.IdUserType
where u.IdUser = @IdUser

else if @IdType = 3
Select u.IdUser, u.IdUserType, [Name], UserLogin, UserName, FirstName, LastName, SecondLastName, AllowToRegisterPc, ChangePasswordAtNextLogin, 
GenericStatus, u.IdGenericStatus, [Address], Cellular, City, Email, Phone, IdUserSellerParent, [State], Zipcode, ISNULL(s.IdCounty, 0) as IdCounty,
ISNULL(CountyName, '') as CountyName
from Users u with (nolock)
left join Seller s with (nolock) on u.IdUser = s.IdUserSeller
left join GenericStatus gs with (nolock) on u.IdGenericStatus = gs.IdGenericStatus
left join UsersType ut with (nolock) on u.IdUserType = ut.IdUserType
left join County c with (nolock) on s.IdCounty = c.IdCounty
where u.IdUser = @IdUser

End try
Begin Catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetUserToEdit]',Getdate(),@ErrorMessage);
End catch

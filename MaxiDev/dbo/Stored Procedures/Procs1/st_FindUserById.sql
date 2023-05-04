CREATE PROCEDURE [dbo].[st_FindUserById]
(
	@IdUser	        INT	
)
AS
BEGIN
	SELECT
	cc.IdUser, cc.UserName, cc.UserLogin, cc.DateOfCreation,cc.CreatedByIdUser, cc.IdUserType, 
	cc.IdGenericStatus, cc.DateOfLastChange, cc.FirstName, cc.LastName, cc.SecondLastName
	FROM Users cc WITH(NOLOCK)
	WHERE cc.IdUser = @IdUser

END
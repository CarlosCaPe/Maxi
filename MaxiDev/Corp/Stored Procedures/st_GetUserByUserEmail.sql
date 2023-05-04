CREATE PROCEDURE Corp.st_GetUserByUserEmail
	@UserEmail	NVARCHAR(100)
AS
BEGIN

	IF EXISTS (SELECT TOP 1 1 FROM dbo.Corporate WHERE Email = @UserEmail)
	BEGIN
		SELECT U.IdUser, U.UserName, U.UserLogin, U.IdUserType, UT.Name AS 'UserType', U.IdGenericStatus, U.salt, u.DateOfCreation
		FROM Users U INNER JOIN
			dbo.Corporate C ON C.IdUserCorporate = U.IdUser INNER JOIN
			dbo.UsersType UT ON UT.IdUserType = U.IdUserType
		WHERE C.Email = @UserEmail
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM dbo.Seller WHERE Email = @UserEmail)
		BEGIN
		
			SELECT U.IdUser, U.UserName, U.UserLogin, U.IdUserType, UT.Name AS 'UserType', U.IdGenericStatus, U.salt, u.DateOfCreation
			FROM Users U INNER JOIN
				dbo.Seller S ON S.IdUserSeller = U.IdUser INNER JOIN
				dbo.UsersType UT ON UT.IdUserType = U.IdUserType
			WHERE S.Email = @UserEmail
		
		END
	END
	
	
END

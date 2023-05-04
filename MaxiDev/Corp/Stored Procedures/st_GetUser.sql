CREATE PROCEDURE  [Corp].[st_GetUser] 
( @IdUser int
)
	as
BEGIN

	SET NOCOUNT ON;

SELECT [IdUser]
      ,[UserName]
      ,[UserLogin]
      ,[UserPassword]
      ,[IdUserType]
      ,[IdGenericStatus]
      ,[salt]
  FROM [dbo].[Users] WITH(nolock)
  WHERE IdUser= @IdUser
END

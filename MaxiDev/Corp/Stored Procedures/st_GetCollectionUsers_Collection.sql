CREATE PROCEDURE [Corp].[st_GetCollectionUsers_Collection]
AS
BEGIN

SET NOCOUNT ON;
	
CREATE TABLE #CollecionUsersCategories (
	IdUser 				INT,
	IdGenericStatus 	INT,
	UserName			VARCHAR(max)
	)
	
DECLARE @CollectionUsers VARCHAR(max)
DECLARE @colusr_querytext NVARCHAR(max)


SELECT @CollectionUsers = Value
FROM GlobalAttributes
WHERE Name = 'CollectionUsers'	
--'15263,15264,15269,15270,15271,15272'

SET @colusr_querytext = N'SELECT IdUser, IdGenericStatus, UserName FROM Users WHERE IdUser IN (' + @CollectionUsers + ')'


INSERT INTO #CollecionUsersCategories
EXEC sp_executesql @colusr_querytext


SELECT A.IdUser, A.UserName, A.IsAdmin, A.IsUser, A.IdGenericStatus
FROM 
(
	SELECT
		U. IdUser
		,U.UserName
	    ,1 AS IsAdmin
	    ,1 AS IsUser
		,U.IdGenericStatus
		,0 AS Tipo  
	FROM #CollecionUsersCategories CU WITH(nolock)
	INNER JOIN Users U WITH (nolock) ON U.IdUser = CU.IdUser
	UNION	
	SELECT
		CU. [IdUser]
		,U.UserName
	    ,CU.[IsAdmin]
	    ,CU.[IsUser]
		,U.IdGenericStatus
		,1 AS Tipo 
	FROM [dbo].[CollectionUsers] CU WITH(nolock)
	INNER JOIN Users U WITH (nolock) ON U.IdUser = CU.IdUser
	WHERE U.IdGenericStatus= 1
) A
ORDER BY A.Tipo, A.UserName ASC

END



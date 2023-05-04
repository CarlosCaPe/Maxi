CREATE PROCEDURE [Corp].[st_GetAllUsersV2]
	@Filter				NVARCHAR(500),
	@Page				INT = 1,
	@IncludeDisabled 	BIT = 1,
	@TotalRows			INT OUTPUT
AS  
SET NOCOUNT ON;
BEGIN TRY

DECLARE @fromRow 		INT



SET @fromRow = 50 * (@Page - 1)


SELECT U.IdUser, U.IdUserType, UT.Name, U.IdGenericStatus, S.GenericStatus, U.UserLogin, U.UserName, isnull(SL.DateOfLastAccess, US.LastAccess) AS 'DateOfLastAccess', A.AgentCode, A.AgentName
FROM Users U  WITH(NOLOCK) INNER JOIN
	UsersType UT WITH(NOLOCK) ON UT.IdUserType = U.IdUserType INNER JOIN
	GenericStatus S WITH(NOLOCK) ON S.IdGenericStatus = U.IdGenericStatus LEFT JOIN
	Corporate C WITH(NOLOCK) ON C.IdUserCorporate = U.IdUser LEFT JOIN
	Seller SL WITH(NOLOCK) ON SL.IdUserSeller = U.IdUser LEFT JOIN
	UsersSession US WITH(NOLOCK) ON US.IdUser = U.IdUser LEFT JOIN
	AgentUser AUS WITH(NOLOCK) ON AUS.IdUser = U.IdUser LEFT JOIN
	Agent A WITH(NOLOCK) ON A.IdAgent = AUS.IdAgent
WHERE ((@IncludeDisabled = 0 AND u.IdGenericStatus IN (1,3)) OR  (@IncludeDisabled = 1))
	AND (U.UserName LIKE '%'+@Filter+'%' OR U.UserLogin LIKE '%'+@Filter+'%' OR C.Email LIKE '%'+@Filter+'%' OR SL.Email LIKE '%'+@Filter+'%' OR A.AgentCode LIKE '%' + @Filter + '%')
ORDER BY U.UserName
OFFSET (@fromRow) ROWS
FETCH NEXT 50 ROWS ONLY


SELECT @TotalRows = count(1)
FROM Users U WITH(NOLOCK) INNER JOIN
	UsersType UT WITH(NOLOCK) ON UT.IdUserType = U.IdUserType INNER JOIN
	GenericStatus S WITH(NOLOCK) ON S.IdGenericStatus = U.IdGenericStatus LEFT JOIN
	Corporate C WITH(NOLOCK) ON C.IdUserCorporate = U.IdUser LEFT JOIN
	Seller SL WITH(NOLOCK) ON SL.IdUserSeller = U.IdUser LEFT JOIN
	UsersSession US WITH(NOLOCK) ON US.IdUser = U.IdUser LEFT JOIN
	AgentUser AUS WITH(NOLOCK) ON AUS.IdUser = U.IdUser LEFT JOIN
	Agent A WITH(NOLOCK) ON A.IdAgent = AUS.IdAgent
WHERE ((@IncludeDisabled = 0 AND u.IdGenericStatus IN (1,3)) OR  (@IncludeDisabled = 1))
	AND (U.UserName LIKE '%'+@Filter+'%' OR U.UserLogin LIKE '%'+@Filter+'%' OR C.Email LIKE '%'+@Filter+'%' OR SL.Email LIKE '%'+@Filter+'%' OR A.AgentCode LIKE '%' + @Filter + '%')




END TRY
BEGIN CATCH
	DECLARE @ErrorMessage varchar(max);
    SELECT @ErrorMessage=ERROR_MESSAGE();
    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES('[Corp].[st_GetAllUsers]',Getdate(),@ErrorMessage);
END CATCH






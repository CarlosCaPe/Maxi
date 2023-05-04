CREATE PROCEDURE [dbo].[st_FetchSeller]
(
	@Name	   			VARCHAR(200),
	@IdUserParent	    BIGINT=NULL,
	@Phone	            VARCHAR(50),
	@Cellular           VARCHAR(50),
    @Email              VARCHAR(200),
    @State              VARCHAR(200),
    @ZipCode            VARCHAR(200),
	@Offset			    BIGINT,
	@Limit			    BIGINT
)
AS
BEGIN

	DECLARE @Records TABLE (Id INT, _PagedResult_Total BIGINT)

	INSERT INTO @Records(Id, _PagedResult_Total)
	SELECT
		cc.IdUserSeller,
		COUNT(*) OVER() _PagedResult_Total
	FROM Seller cc WITH(NOLOCK)
	JOIN Users pc WITH(NOLOCK) ON cc.IdUserSeller = pc.IdUser
	WHERE
			(@Name IS NULL OR pc.UserName LIKE CONCAT('%', @Name, '%')) -- @Name
		AND ((@IdUserParent IS NULL) OR (cc.IdUserSellerParent = @IdUserParent)) -- @IdUserParent
		AND (@Phone IS NULL OR (cc.Phone = @Phone )) -- @Phone
		AND (@Cellular IS NULL OR (cc.Cellular = @Cellular)) --@Cellular
		AND (@Email IS NULL OR (cc.Email = @Email)) --@Email
		AND (@State IS NULL OR (cc.State = @State))  --@State
		AND (@ZipCode IS NULL OR (cc.Zipcode = @ZipCode))  ---@ZipCode
	ORDER BY IdUserSeller
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

	SELECT
		cc.IdUserSeller, 
		cc.Zipcode, 
		cc.State, 
		cc.City,
		cc.Address, 
		cc.Phone, 
		cc.Cellular, 
	    cc.Email, 
	    cc.IdUserSellerParent, 
		cc.DateOfLastAccess, 
		cc.IdCounty,
		r._PagedResult_Total
	FROM Seller cc WITH(NOLOCK)
		JOIN @Records r ON r.Id = cc.IdUserSeller

	SELECT
		pc.IdUser,
		pc.UserName,
		pc.UserLogin,
		pc.DateOfCreation,
		pc.CreatedByIdUser,
		pc.IdUserType,
		pc.IdGenericStatus,
		pc.DateOfLastChange,
		pc.FirstName,
		pc.LastName,
		pc.SecondLastName
	FROM Users pc WITH(NOLOCK)
		JOIN @Records r ON r.Id = pc.IdUser

END
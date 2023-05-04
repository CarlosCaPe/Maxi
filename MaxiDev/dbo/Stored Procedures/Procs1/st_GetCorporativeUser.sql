CREATE PROCEDURE st_GetCorporativeUser
(
	@IdUser		INT
)
AS
BEGIN
	SELECT
		u.IdUser,
		u.UserName,
		u.UserLogin,
		c.ZipCode,
		c.State,
		c.City,
		c.Address,
		c.Phone,
		c.Cellular,
		c.Email,
		c.IdCounty
	FROM Corporate c
	JOIN Users u ON u.IdUser = c.IdUserCorporate
	WHERE u.IdUser = @IdUser
END
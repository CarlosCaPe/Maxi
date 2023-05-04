CREATE PROCEDURE [dbo].[st_FindSellerById]
(
	@IdSeller	        INT
	
)
AS
BEGIN
	SELECT
	cc.IdUserSeller, cc.Zipcode, cc.State, cc.City,cc.Address, cc.Phone, cc.Cellular, cc.Email, cc.IdUserSellerParent, cc.DateOfLastAccess, cc.IdCounty
	FROM Seller cc WITH(NOLOCK)
	JOIN Users pc WITH(NOLOCK) ON cc.IdUserSeller = pc.IdUser
	WHERE cc.IdUserSeller = @IdSeller
	Order by cc.IdUserSeller

END
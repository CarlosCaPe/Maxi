CREATE PROCEDURE Corp.st_GetOfacValidationReviewHistory
	@IdOfacValidationDetail	INT
AS
BEGIN
	
	SELECT H.IdOfacValidationReviewHistory, H.IdOfacValidationDetail, isnull(U.UserName, '') AS 'ReviewUser', H.DateOfReview
	FROM Corp.OfacValidationReviewHistory H LEFT JOIN
		dbo.Users U ON U.IdUser = H.IdUser
	WHERE IdOfacValidationDetail = @IdOfacValidationDetail
	ORDER BY H.DateOfReview DESC

END

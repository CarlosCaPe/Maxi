CREATE PROCEDURE Corp.st_InsertOfacValidationReviewHistory
	@IdOfacValidationDetail	INT,
	@IdUser					INT
AS
BEGIN

	IF NOT EXISTS (SELECT * FROM Corp.OfacValidationReviewHistory WHERE IdOfacValidationDetail = @IdOfacValidationDetail 
																	AND IdUser = @IdUser 
																	AND convert(DATE, getdate()) = convert(DATE, DateOfReview))
	BEGIN
	
		INSERT INTO Corp.OfacValidationReviewHistory (IdOfacValidationDetail, IdUser, DateOfReview)
		VALUES (@IdOfacValidationDetail, @IdUser, getdate())	
	
	END	
	
END



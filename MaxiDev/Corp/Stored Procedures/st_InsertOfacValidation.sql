CREATE PROCEDURE Corp.st_InsertOfacValidation
	@FileName			VARCHAR(100),
	@IdUser				INT,
	@IdOfacValidation 	INT OUTPUT
AS
BEGIN

	INSERT INTO Corp.OfacValidation (FileName, DateOfCreation, IdUser)
	VALUES (@FileName, getdate(), @IdUser)
	
	SET @IdOfacValidation = @@IDENTITY
	

END

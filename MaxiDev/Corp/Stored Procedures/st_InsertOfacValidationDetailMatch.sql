CREATE PROCEDURE Corp.st_InsertOfacValidationDetailMatch
	@idofacvalidationdetail INT,
	@score 					DECIMAL(5,2),
	@status					NVARCHAR(50),
	@entnum					INT,
	@altnum					INT,
	@name					NVARCHAR(100),
	@lastname				NVARCHAR(100),
	@namecomplete			NVARCHAR(100),
	@remarks				NVARCHAR(max),
	@type					NVARCHAR(50),
	@address				NVARCHAR(150),
	@cityname				NVARCHAR(150),
	@country				NVARCHAR(150),
	@addremarks				NVARCHAR(150),
	@idusercreation			INT,
	@IdOfacValidationDetailMatch INT OUTPUT
AS
BEGIN

	DECLARE @IdOfacValidationEntityType INT
	
	SELECT @IdOfacValidationEntityType = IdOfacValidationEntityType 
	FROM Corp.OfacValidationEntityType
	WHERE Name = @type

	INSERT INTO Corp.OfacValidationDetailMatch
	(
		IdOfacValidationDetail,
		Score,
		Status,
		EntNum,
		AltNum,
		Name,
		LastName,
		NameComplete,
		Remarks,
		IdOfacValidationEntityType,
		Address,
		CityName,
		Country,
		AddRemarks,
		IdUserCreation,
		DateOfCreation
	)
	VALUES 
	(
		@idofacvalidationdetail,
		@score,
		@status,
		@entnum,
		@altnum,
		@name,
		@lastname,
		@namecomplete,
		@remarks,
		@IdOfacValidationEntityType,
		@address,
		@cityname,
		@country,
		@addremarks,
		@idusercreation,
		getdate()
	)
	
	SET @IdOfacValidationDetailMatch = @@IDENTITY
	
END



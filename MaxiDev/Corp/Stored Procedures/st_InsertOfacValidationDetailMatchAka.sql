CREATE PROCEDURE Corp.st_InsertOfacValidationDetailMatchAka
	@idofacvalidationdetailmatch	INT,
	@score 							DECIMAL(5,2),
	@status					 		NVARCHAR(50),
	@entnum							INT,
	@altnum					 		INT,
	@name				  			NVARCHAR(100),
	@lastname			 			NVARCHAR(100),
	@namecomplete		 			NVARCHAR(100),
	@remarks			 			NVARCHAR(max),
	@type				 			NVARCHAR(50),
	@address			 			NVARCHAR(150),
	@cityname			 			NVARCHAR(150),
	@country			 			NVARCHAR(150),
	@addremarks			 			NVARCHAR(150),
	@idusercreation		 			INT,
	@IdOfacValidationDetailMatchAka	INT OUTPUT
AS
BEGIN


	INSERT INTO Corp.OfacValidationDetailMatchAka
	(
		IdOfacValidationDetailMatch,
		Score,
		Status,
		EntNum,
		AltNum,
		Name,
		LastName,
		NameComplete,
		Remarks,
		Type,
		Address,
		CityName,
		Country,
		AddRemarks,
		IdUserCreation,
		DateOfCreation
	)
	VALUES 
	(
		@idofacvalidationdetailmatch,
		@score,
		@status,
		@entnum,
		@altnum,
		@name,
		@lastname,
		@namecomplete,
		@remarks,
		@type,
		@address,
		@cityname,
		@country,
		@addremarks,
		@idusercreation,
		getdate()
	)
	
	SET @IdOfacValidationDetailMatchAka = @@IDENTITY
	
END


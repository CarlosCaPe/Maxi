CREATE PROCEDURE Corp.st_InsertOfacValidationDetail
	@IdOfacValidation		INT,
	@Name					NVARCHAR(100),
	@DateOfBirth			DATETIME,
	@CountryOfBirth			NVARCHAR(50),
	@EntityType				NVARCHAR(50),
	@HasMatch				BIT,
	@GeneralStatus			NVARCHAR(50),
	@GeneralMessage			NVARCHAR(max),
	@Filter					NVARCHAR(50),
	@IdUserCreation			INT,
	@IdOfacValidationDet	INT OUTPUT
AS
BEGIN

	DECLARE @IdOfacValidationEntityType INT
	DECLARE @NewStatus NVARCHAR(50)
	DECLARE @IsAutomaticDiscard	BIT = 0
	DECLARE @IdUserSystem	INT
	
	SELECT @IdUserSystem = convert(INT, Value)
	FROM GlobalAttributes WHERE Name = 'SystemUserID'
	
	
	IF(@GeneralStatus = 'NoMatch')
	BEGIN
		SELECT @NewStatus = 'NoMatch'
		SELECT @IsAutomaticDiscard = 1
	END
		
	IF(@GeneralStatus = 'DiscardMatch')
	BEGIN
	
		SELECT @NewStatus = 'MatchButDiscarded'
		SELECT @IsAutomaticDiscard = 1
	END
		
	IF(@GeneralStatus = 'Match' OR @GeneralStatus = 'FullMatch')
		SELECT @NewStatus = 'PossibleMatch'
		
	
	SELECT @IdOfacValidationEntityType = IdOfacValidationEntityType 
	FROM Corp.OfacValidationEntityType
	WHERE Name = @EntityType

   	INSERT INTO Corp.OfacValidationDetail
	(
		IdOfacValidation,
		Name,
		DateOfBirth,
		CountryOfBirth,
		IdOfacValidationEntityType,
		HasMatch,
		GeneralStatus,
		Filter,
		IdUserApprove,
		DateOfApproval,
		StatusChangeNote,
		IdUserCreation,
		DateOfCreation,
		GeneralMessage
	)
	VALUES 
	(
		@IdOfacValidation,
		@Name,
		@DateOfBirth,
		@CountryOfBirth,
		@IdOfacValidationEntityType,
		@HasMatch,
		@NewStatus,
		@Filter,
		CASE WHEN @IsAutomaticDiscard = 1 THEN @IdUserSystem ELSE NULL END,
		CASE WHEN @IsAutomaticDiscard = 1 THEN getdate() ELSE NULL END,
		CASE WHEN @IsAutomaticDiscard = 1 THEN @GeneralMessage ELSE '' END,
		@IdUserCreation,
		getdate(),
		@GeneralMessage
	)
	
	SET @IdOfacValidationDet = @@IDENTITY
	
END



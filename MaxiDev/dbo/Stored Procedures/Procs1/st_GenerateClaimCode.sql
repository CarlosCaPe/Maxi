CREATE PROCEDURE st_GenerateClaimCode
(
	@ProfileKey				VARCHAR(200)
	--, @TimeOut				VARCHAR(50) = NULL
)
AS
BEGIN
	DECLARE @MSG_ERROR NVARCHAR(500)

	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE
			@Prefix						NVARCHAR(100),
			@RandomCharacters			INT,
			@AcceptableCharacters		NVARCHAR(100),
			@FixedLength				BIT,
			@Length						TINYINT,
			@Filler						CHAR,
			@IncludePrefix				BIT,
			@FixedRange					BIT,
			@MinRange					BIGINT,
			@MaxRange					BIGINT,
			@CurrentNumber				BIGINT
		
		SELECT
			@Prefix = Prefix,
			@RandomCharacters = RandomCharacters,
			@AcceptableCharacters = AcceptableCharacters,
			@FixedLength = ISNULL(FixedLength, 0),
			@Length = Length,
			@Filler = Filler,
			@IncludePrefix = ISNULL(IncludePrefix, 0),
			@FixedRange = ISNULL(FixedRange, 0),
			@MinRange = MinRange,
			@MaxRange = MaxRange,
			@CurrentNumber = CurrentNumber
		FROM ClaimCodeProfile c WITH(XLOCK, ROWLOCK) 
		WHERE c.ProfileKey = @ProfileKey

		-- Profile key not exists
		IF @Prefix IS NULL
		BEGIN
			SET @MSG_ERROR = 'Profile key not exists'
			RAISERROR(@MSG_ERROR, 16, 1);
		END

		-- Increment current number
		SET @CurrentNumber = @CurrentNumber + 1

		-- Validate if has fixed range
		IF (
			ISNULL(@FixedRange, 0) = 1 
			AND (@MinRange IS NULL AND @MaxRange IS NULL) 
			AND NOT (@CurrentNumber >= @MinRange AND  @CurrentNumber <= @MaxRange)
		)
		BEGIN
			SET @MSG_ERROR = 'Profile current number is out of range, please verify it!'
			RAISERROR(@MSG_ERROR, 16, 1);
		END

		-- Update current number
		UPDATE ClaimCodeProfile WITH(XLOCK, ROWLOCK) SET 
			CurrentNumber = @CurrentNumber  
		WHERE ProfileKey = @ProfileKey

		--IF @TimeOut IS NOT NULL
		--	WAITFOR DELAY @TimeOut
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		IF(ISNULL(@MSG_ERROR, '') = '')
			SET @MSG_ERROR = ERROR_MESSAGE();

		RAISERROR(@MSG_ERROR, 16, 1);
	END CATCH

	DECLARE @ClaimPrefix		NVARCHAR(10),
			@ClaimNumber		NVARCHAR(30),
			@ClaimRamdomChar	NVARCHAR(1)

	-- Set prefix if profile include it
	SET @ClaimPrefix = IIF(@IncludePrefix = 1, @Prefix, '')

	IF @RandomCharacters = 1
		SET @ClaimRamdomChar = SUBSTRING(
			@AcceptableCharacters, 
			CAST(RAND()*(LEN(@AcceptableCharacters)) AS INT),
			1
		);

	IF (@FixedLength = 1)
	BEGIN
		IF LEN(CONCAT(@ClaimPrefix, @CurrentNumber, @ClaimRamdomChar)) > @Length
		BEGIN
			SET @MSG_ERROR = 'The Claim Code length exceeds the fix length number value'
			RAISERROR(@MSG_ERROR, 16, 1);
			RETURN
		END

		SET @ClaimNumber = RIGHT(CONCAT(REPLICATE(@Filler, @Length), @CurrentNumber), @Length - LEN(CONCAT(@ClaimPrefix, @ClaimRamdomChar)))
	END
	ELSE IF (@FixedRange = 1)
		SET @ClaimNumber = @CurrentNumber
	ELSE
		SET @ClaimNumber = RIGHT(CONCAT('0000000', @CurrentNumber), 6)

	-- Generate claimcode afther commit transaction
	SELECT CONCAT(@ClaimPrefix, @ClaimNumber, @ClaimRamdomChar) random_value
END
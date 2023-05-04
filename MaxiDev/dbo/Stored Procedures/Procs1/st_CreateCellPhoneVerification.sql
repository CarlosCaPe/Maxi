CREATE PROCEDURE st_CreateCellPhoneVerification
(
	@PhoneNumber				VARCHAR(20),
	@EnterByIdUser				INT,

	@IdCellPhoneVerification	INT OUT
)
AS
BEGIN
	DECLARE @CurrentDate		DATETIME,
			@ExpirationDate		DATETIME,
			@VerificationCode	VARCHAR(20)

	SET @CurrentDate = GETDATE()
	SET @ExpirationDate = DATEADD(MINUTE, 30, GETDATE())

	SET @VerificationCode = FLOOR(RAND() * (5001));
	SET @VerificationCode = RIGHT(CONCAT('00000', @VerificationCode), 5)

	INSERT INTO CellPhoneVerification(PhoneNumber, VerificationCode, CreationDate, ExpirationDate, Applied, EnterByIdUser)
	VALUES (@PhoneNumber, @VerificationCode, @CurrentDate, @ExpirationDate, 0, @EnterByIdUser)

	SET @IdCellPhoneVerification = @@identity
END

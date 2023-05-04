CREATE PROCEDURE st_AppliedCellPhoneVerificationCode
(
	@IdCellPhoneVerification	INT,
	@VerificationCode			VARCHAR(20),
	@IdLanguage					INT,

	@Success					BIT OUT,
	@ErrorMessage				VARCHAR(500) OUT
)
AS
BEGIN
	DECLARE @CurrentDate		DATETIME,
			@ExpirationDate		DATETIME,
			@Applied			BIT,
			@SendAgain			BIT

	IF @IdLanguage NOT IN (1, 2)
		SET @IdLanguage = 1

	SELECT
		@CurrentDate = cv.CreationDate,
		@ExpirationDate = cv.ExpirationDate,
		@Applied = cv.Applied
	FROM CellPhoneVerification cv
	WHERE 
		cv.IdCellPhoneVerification = @IdCellPhoneVerification
		AND cv.VerificationCode = @VerificationCode


	SELECT @CurrentDate, @ExpirationDate, @Applied

	IF ISNULL(@VerificationCode, '') = ''
		SET @ErrorMessage = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage, 'CellPhoneVerification_EmptyCode')
	ELSE IF @Applied IS NULL
		SET @ErrorMessage = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage, 'CellPhoneVerification_InvalidCode')
	ELSE IF (GETDATE() > @ExpirationDate )
		SET @ErrorMessage = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage, 'CellPhoneVerification_ExpiredCode')
	ELSE IF (@Applied = 1)
		SET @ErrorMessage = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage, 'CellPhoneVerification_AppliedCode')

	SET @Success = IIF(ISNULL(@ErrorMessage, '') = '', 1, 0)

	IF @Success = 1
		UPDATE CellPhoneVerification SET
			Applied = 1
		WHERE IdCellPhoneVerification = @IdCellPhoneVerification
END

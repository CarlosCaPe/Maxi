CREATE PROCEDURE st_VerifyCellPhoneVerificationCode
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
		SET @ErrorMessage = 'Codigo vacio'
	ELSE IF @Applied IS NULL
		SET @ErrorMessage = 'Codigo no valido'
	ELSE IF (GETDATE() > @ExpirationDate )
		SET @ErrorMessage = 'Expirado'
	ELSE IF (@Applied = 1)
		SET @ErrorMessage = 'Aplicado'

	SET @Success = IIF(ISNULL(@ErrorMessage, '') = '', 1, 0)

	--IF @Success = 1
	--	UPDATE CellPhoneVerification SET
	--		Applied = 1
	--	WHERE IdCellPhoneVerification = @IdCellPhoneVerification
END

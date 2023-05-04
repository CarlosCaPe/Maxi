CREATE PROCEDURE st_AppliedCustomerCellPhoneChange
(
	@IdCustomer					INT,
	@IdCellPhoneVerification	INT,
	@VerificationCode			VARCHAR(20),
	@IdLanguage					INT,
	@IdUser						INT,

	@Success					BIT OUT,
	@ErrorMessage				VARCHAR(500) OUT
)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

		EXEC st_AppliedCellPhoneVerificationCode @IdCellPhoneVerification,  @VerificationCode, @IdLanguage, @Success OUT, @ErrorMessage OUT

		IF @Success = 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END

		IF @IdCustomer = 0
			SET @IdCustomer = NULL

		SET @ErrorMessage = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage, 'CellPhoneVerification_Success')

		DECLARE @PhoneNumber	VARCHAR(200)
		DECLARE @OldCustomers TABLE(IdCustomer	INT, SaveMirror BIT)

		SELECT
			@PhoneNumber = cv.PhoneNumber
		FROM CellPhoneVerification cv
		WHERE cv.IdCellPhoneVerification = @IdCellPhoneVerification

		INSERT INTO @OldCustomers(IdCustomer, SaveMirror)
		SELECT
			c.IdCustomer, 0
		FROM Customer c 
		WHERE c.CelullarNumber = @PhoneNumber

		-- Remove olds numbers
		DECLARE @CurrentIdCustomer INT
		WHILE EXISTS(SELECT 1 FROM @OldCustomers oc WHERE oc.SaveMirror = 0)
		BEGIN
			SELECT TOP 1
				@CurrentIdCustomer = oc.IdCustomer
			FROM @OldCustomers oc 
			WHERE oc.SaveMirror = 0
		
			EXEC st_SaveCustomerMirror @CurrentIdCustomer

			UPDATE @OldCustomers SET SaveMirror = 1 WHERE IdCustomer = @CurrentIdCustomer
		END
		UPDATE c SET
			c.CelullarNumber = NULL,
			RequestUpdate = 1,
			UpdateCompleted = 0
		FROM Customer c
			JOIN @OldCustomers oc ON oc.IdCustomer = c.IdCustomer

		IF @IdCustomer IS NOT NULL
		BEGIN
			-- Update current customer
			EXEC st_SaveCustomerMirror @IdCustomer
			UPDATE c SET
				c.CelullarNumber = @PhoneNumber,
				RequestUpdate = 1,
				UpdateCompleted = 0
			FROM Customer c
			WHERE c.IdCustomer = @IdCustomer
		END

		INSERT INTO CustomerCellPhoneVerificationRelation (IdCellPhoneVerification, IdCustomer, OldCustomer, CreationDate, EnterByIdUser)
		VALUES (@IdCellPhoneVerification, @IdCustomer, (SELECT o.IdCustomer, o.SaveMirror FROM @OldCustomers o FOR XML PATH),GETDATE(), @IdUser)


		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		IF(ISNULL(@ErrorMessage, '') = '')
			SET @ErrorMessage = ERROR_MESSAGE();

		SET @Success = 0
	END CATCH
END
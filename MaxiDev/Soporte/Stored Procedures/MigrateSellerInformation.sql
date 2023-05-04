CREATE PROCEDURE Soporte.MigrateSellerInformation
(
    @IdPayer            INT,
    @IdPayerSurrogate   INT

)
AS
BEGIN
    DECLARE @ErrorMessage VARCHAR(200)

    IF @IdPayer = @IdPayerSurrogate
        SET @ErrorMessage = 'The IdPayer''s cannot be equals'
    ELSE IF NOT EXISTS (SELECT 1 FROM Payer p WHERE p.IdPayer = @IdPayer)
        SET @ErrorMessage = 'The IdPayer not exists'
    ELSE IF NOT EXISTS (SELECT 1 FROM Payer p WHERE p.IdPayer = @IdPayerSurrogate)
        SET @ErrorMessage = 'The IdPayerSurrogate not exists'

    IF ISNULL(@ErrorMessage, '') <> ''
        RAISERROR(@ErrorMessage, 16, 1);

	IF NOT EXISTS (SELECT 1 FROM PayerSurrogateConfig WHERE IdPayer = @IdPayer AND IdPayerSurrogate = @IdPayerSurrogate)
		INSERT INTO PayerSurrogateConfig(IdPayer, IdPayerSurrogate)
		VALUES (@IdPayer, @IdPayerSurrogate)

    DELETE FROM PayerSurrogateConfig WHERE IdPayerSurrogate = @IdPayer

    DECLARE @CurrentDate DATETIME = GETDATE()

    UPDATE t SET
	    t.idPayer = @IdPayerSurrogate
    OUTPUT INSERTED.IdTransfersCustomerInfoByPayer, DELETED.idPayer, INSERTED.idPayer, @CurrentDate
    INTO Soporte.CustomerDepositAccountMigration(IdTransfersCustomerInfoByPayer, IdPayerOriginal, IdPayerNew, DateOfChange)
    FROM TransfersCustomerInfoByPayer t
    WHERE t.idPayer = @IdPayer

	UPDATE Payer SET
		IdGenericStatus = 2,
		DateOfLastChange = @CurrentDate
	WHERE IdPayer = @IdPayer

    SELECT @IdPayer, @IdPayerSurrogate, @CurrentDate
END
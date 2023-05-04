CREATE PROCEDURE Soporte.MigrateDepositAccountInformation
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

	-- Se mueve directo ya que solo existen en @IdPayer
	UPDATE t SET
		t.idPayer = @IdPayerSurrogate
	OUTPUT INSERTED.IdTransfersCustomerInfoByPayer, DELETED.idPayer, INSERTED.idPayer, @CurrentDate
	INTO Soporte.CustomerDepositAccountMigration(IdTransfersCustomerInfoByPayer, IdPayerOriginal, IdPayerNew, DateOfChange)
	--SELECT *
	FROM TransfersCustomerInfoByPayer t
		LEFT JOIN TransfersCustomerInfoByPayer x ON x.idCustomer = t.idCustomer AND x.idBeneficiary = t.idBeneficiary AND x.idPayer = @IdPayerSurrogate
	WHERE 
		t.IdPayer = @IdPayer
		AND x.IdTransfersCustomerInfoByPayer IS NULL

	-- Se valida si se mueve, ya que existe en ambos

	DECLARE @FinalConflictAccounts TABLE(IdCustomer INT, IdBeneficiary INT, IdTransfer INT, IdPayer INT, DepositAccountNumber NVARCHAR(MAX))

	-- Se obtienen Clientes y Beneficiarios con conflicto
	;WITH ConflictCustomer AS (
		SELECT t.idCustomer, t.idBeneficiary
		FROM TransfersCustomerInfoByPayer t
			LEFT JOIN TransfersCustomerInfoByPayer x ON x.idCustomer = t.idCustomer AND x.idBeneficiary = t.idBeneficiary AND x.idPayer = @IdPayerSurrogate
		WHERE 
			t.IdPayer = @IdPayer
			AND x.IdTransfersCustomerInfoByPayer IS NOT NULL
	),
	-- Se obtiene los numeros de cuenta en conflicto
	ConflictAccounts AS (
		SELECT 
			t.IdTransfer, t.IdCustomer, t.IdBeneficiary, t.IdPayer, t.DepositAccountNumber 
		FROM Transfer t
			JOIN ConflictCustomer cc ON cc.idCustomer = t.IdCustomer AND cc.idBeneficiary = t.IdBeneficiary
		WHERE t.IdPayer IN (@IdPayer, @IdPayerSurrogate)
		UNION ALL
		SELECT 
			t.IdTransferClosed IdTransfer, t.IdCustomer, t.IdBeneficiary, t.IdPayer, t.DepositAccountNumber 
		FROM TransferClosed t
			JOIN ConflictCustomer cc ON cc.idCustomer = t.IdCustomer AND cc.idBeneficiary = t.IdBeneficiary
		WHERE t.IdPayer IN (@IdPayer, @IdPayerSurrogate)
	),
	-- Se obtiene el ultimo numero de cuenta que se haya utilizado este es el que se conservara
	LastTransferByCustomer AS (
		SELECT 
			ca.IdCustomer,
			ca.IdBeneficiary,
			MAX(ca.IdTransfer) IdTransfer
		FROM ConflictAccounts ca
		GROUP BY ca.IdCustomer, ca.IdBeneficiary
	)
	INSERT INTO @FinalConflictAccounts
	SELECT 
		l.IdCustomer,
		l.IdBeneficiary,
		l.IdTransfer,
		ca.IdPayer,
		ca.DepositAccountNumber
	FROM LastTransferByCustomer l
		JOIN ConflictAccounts ca ON ca.IdTransfer = l.IdTransfer


	UPDATE t SET
		t.DepositAccountNumber = fca.DepositAccountNumber,
		t.idPayer = @IdPayerSurrogate
	OUTPUT INSERTED.IdTransfersCustomerInfoByPayer, DELETED.idPayer, INSERTED.idPayer, @CurrentDate
	INTO Soporte.CustomerDepositAccountMigration(IdTransfersCustomerInfoByPayer, IdPayerOriginal, IdPayerNew, DateOfChange)
	--SELECT 
	--	t.*,
	--	fca.DepositAccountNumber NewDepositAccountNumber
	FROM TransfersCustomerInfoByPayer t
		JOIN @FinalConflictAccounts fca ON fca.IdCustomer = t.idCustomer AND fca.IdBeneficiary = t.idBeneficiary
	WHERE t.idPayer IN (@IdPayer, @IdPayerSurrogate)


	UPDATE Payer SET
		IdGenericStatus = 2,
		DateOfLastChange = @CurrentDate
	WHERE IdPayer = @IdPayer

    SELECT @IdPayer, @IdPayerSurrogate, @CurrentDate
END
--GO
--EXEC Soporte.MigrateDepositAccountInformation 5358, 504



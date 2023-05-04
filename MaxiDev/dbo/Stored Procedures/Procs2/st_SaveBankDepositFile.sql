CREATE PROCEDURE st_SaveBankDepositFile
(
	@IdBankDepositFile		INT OUT,
	@IdAgentBankDeposit		INT,
	@FileDate				DATE,
	@FileName				VARCHAR(200),
	@Deposits				XML,

	@IdUser					INT,
	@HasError				BIT OUT,
    @Message				VARCHAR(MAX) OUT
)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO BankDepositFile(IdAgentBankDeposit, FileDate, FileName, Processed, CreationDate, IdUser)
		VALUES 
		(@IdAgentBankDeposit, @FileDate, @FileName, 0, GETDATE(), @IdUser)

		SET @IdBankDepositFile = @@identity

		INSERT INTO BankDeposit(IdBankDepositFile, DepositDate, Description, Amount, Sign, Reference, Details, TransactionDate)
		SELECT
			@IdBankDepositFile,
			t.c.value('DepositDate[1]', 'datetime'),
			t.c.value('Description[1]', 'varchar(200)'),
			t.c.value('Amount[1]', 'money'),
			t.c.value('Sign[1]', 'int'),
			t.c.value('Reference[1]', 'varchar(200)'),
			t.c.value('Details[1]', 'varchar(1000)'),
			t.c.value('TransactionDate[1]', 'datetime')
		FROM @Deposits.nodes('//root/Record') t(c)

		SET @HasError = 0
		SET @Message = NULL

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @MSG_ERROR NVARCHAR(500) = ERROR_MESSAGE();

		SET @HasError = 1
		SET @Message = 'Error executing the process'

		INSERT INTO ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @MSG_ERROR);
	END CATCH
END

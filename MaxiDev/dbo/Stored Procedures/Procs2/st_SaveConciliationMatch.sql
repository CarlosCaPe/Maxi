CREATE PROCEDURE st_SaveConciliationMatch
(
	@MatchedRecords			XML,

	@IdUser					INT,
	@HasError				BIT OUT,
    @Message				VARCHAR(MAX) OUT
)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @MatchRecords TABLE (IdBankDeposit INT, IdAgentBalance INT)
		DECLARE @ErrorRecords TABLE (IdBankDeposit INT, IdAgentBalance INT, ErrorMessage VARCHAR(1000))


		INSERT INTO @MatchRecords(IdBankDeposit, IdAgentBalance)
		SELECT
			t.c.value('IdBankDeposit[1]', 'int') IdBankDeposit,
			t.c.value('IdAgentBalance[1]', 'int') IdAgentBalance
		FROM @MatchedRecords.nodes('/root/Record') t(c)

		-- Validations
		INSERT INTO @ErrorRecords(IdBankDeposit, IdAgentBalance, ErrorMessage)
		SELECT bd.IdBankDeposit, ad.IdAgentDeposit, CONCAT('The bank deposit (', bd.Description,') amount ($', bd.Amount,') don''t match with amount of the agent deposit ($', ad.Amount,')')
		FROM @MatchRecords mr
			JOIN BankDeposit bd WITH(NOLOCK) ON bd.IdBankDeposit = mr.IdBankDeposit
			JOIN AgentDeposit ad WITH(NOLOCK) ON ad.IdAgentBalance = mr.IdAgentBalance
		WHERE 
			bd.Amount <> ad.Amount

		INSERT INTO @ErrorRecords(IdBankDeposit, IdAgentBalance, ErrorMessage)
		SELECT mr.IdBankDeposit, ad.IdAgentDeposit, CONCAT('The agent''s deposit (', ad.BankName,' $', ad.Amount,') has already been reconciled')
		FROM @MatchRecords mr
			LEFT JOIN AgentDeposit ad WITH(NOLOCK) ON ad.IdAgentBalance = mr.IdAgentBalance
			JOIN ConciliationMatch cm WITH(NOLOCK) ON cm.IdAgentDeposit = ad.IdAgentDeposit
		WHERE ad.IdAgentDeposit IS NOT NULL

		IF EXISTS (SELECT 1 FROM @ErrorRecords)
		BEGIN
			SET @HasError = 1
			SET @Message = STUFF((SELECT CONCAT(CHAR(13), er.ErrorMessage) FROM @ErrorRecords er FOR XML PATH('')), 1, 6, '')
		END
		ELSE
		BEGIN
			INSERT INTO ConciliationMatch (IdBankDeposit, IdAgentDeposit, CreationDate, IdUser)
			SELECT 
				mr.IdBankDeposit,
				ad.IdAgentDeposit,
				GETDATE(),
				@IdUser
			FROM @MatchRecords mr 
				JOIN AgentDeposit ad WITH(NOLOCK) ON ad.IdAgentBalance = mr.IdAgentBalance

			SET @HasError = 0
			SET @Message = NULL
		END

		;WITH Files AS (
			SELECT DISTINCT
				f.IdBankDepositFile
			FROM BankDeposit bd
				JOIN @MatchRecords mr ON mr.IdBankDeposit = bd.IdBankDeposit
				JOIN BankDepositFile f ON f.IdBankDepositFile = bd.IdBankDepositFile
		), ProcessedFiles AS (
			SELECT 
				f.IdBankDepositFile
			FROM Files f
				JOIN BankDeposit bd ON bd.IdBankDepositFile = f.IdBankDepositFile
				LEFT JOIN ConciliationMatch cm ON cm.IdBankDeposit = bd.IdBankDeposit
			GROUP BY f.IdBankDepositFile
			HAVING COUNT(bd.IdBankDeposit) = COUNT(cm.IdConciliationMatch)
		) 
		UPDATE bdf SET
			bdf.Processed = 1
		FROM BankDepositFile bdf
			JOIN ProcessedFiles pf ON pf.IdBankDepositFile = bdf.IdBankDepositFile

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

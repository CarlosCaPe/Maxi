CREATE PROCEDURE st_SaveSettlement
(
	@IdAgentPosTerminal			INT,

	@TerminalId                 VARCHAR(200),
	@HostResponseCode           VARCHAR(200),
	@HostResponseText           VARCHAR(200),
	@MerchantId                 VARCHAR(200),
	@TransactionDate            VARCHAR(200),
	@TransactionTime            VARCHAR(200),

	@TerminalTotal				XML,
	@GiftTotal					XML,
	@IdUser						INT,

	@HasError					BIT OUT,
    @Message					VARCHAR(MAX) OUT
)
AS
BEGIN 
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @IdPosTerminal	INT,
				@IdAgent		INT

		SELECT
			@IdPosTerminal = apt.IdPosTerminal,
			@IdAgent = apc.IdAgent
		FROM AgentPosTerminal apt WITH(NOLOCK)
			JOIN AgentPosMerchant apm WITH(NOLOCK) ON apm.IdAgentPosMerchant = apt.IdAgentPosMerchant
			JOIN AgentPosAccount apc WITH(NOLOCK) ON apc.IdAgentPosAccount = apm.IdAgentPosAccount
		WHERE apt.IdAgentPosTerminal = @IdAgentPosTerminal
		

		INSERT INTO PosSettlement
		(
			IdPosTerminal, 
			IdAgent, 
			HostResponseCode, 
			HostResponseText, 
			MerchantId, 
			TerminalId, 
			TransactionDate, 
			TransactionTime, 
			CreationDate, 
			IdUser
		)
		VALUES
		(
			@IdPosTerminal,
			@IdAgent,
			@HostResponseCode,
			@HostResponseText,
			@MerchantId,
			@TerminalId,
			@TransactionDate,
			@TransactionTime,
			GETDATE(),
			@IdUser
		)

		DECLARE @IdPosSettlement INT = @@identity

		INSERT INTO PosSettlementTerminalTotal
		(
			IdPosSettlement,
			CashbackAmount,
			RefundAmount,
			RefundCount,
			SaleAmount,
			SaleCount,
			SurchargeAmount,
			TipAmount,
			TotalAmount,
			TotalCount,
			VoidAmount,
			VoidCashbackAmount,
			VoidCount,
			VoidSurchargeAmount,
			VoidTipAmount
		)
		SELECT
			@IdPosSettlement,
			t.c.value('CashbackAmount[1]', 'VARCHAR(200)'),
			t.c.value('RefundAmount[1]', 'VARCHAR(200)'),
			t.c.value('RefundCount[1]', 'VARCHAR(200)'),
			t.c.value('SaleAmount[1]', 'VARCHAR(200)'),
			t.c.value('SaleCount[1]', 'VARCHAR(200)'),
			t.c.value('SurchargeAmount[1]', 'VARCHAR(200)'),
			t.c.value('TipAmount[1]', 'VARCHAR(200)'),
			t.c.value('TotalAmount[1]', 'VARCHAR(200)'),
			t.c.value('TotalCount[1]', 'VARCHAR(200)'),
			t.c.value('VoidAmount[1]', 'VARCHAR(200)'),
			t.c.value('VoidCashbackAmount[1]', 'VARCHAR(200)'),
			t.c.value('VoidCount[1]', 'VARCHAR(200)'),
			t.c.value('VoidSurchargeAmount[1]', 'VARCHAR(200)'),
			t.c.value('VoidTipAmount[1]', 'VARCHAR(200)')
		FROM @TerminalTotal.nodes('/TerminalTotal/PosSettlementTerminalTotal') t(c)  

		INSERT INTO PosSettlementGiftTotal 
		(
			IdPosSettlement,
			ActivationAmount,
			ActivationCount,
			Amount,
			[Count],
			RedemptionAmount,
			RedemptionCount,
			RefundAmount,
			RefundCount,
			ReloadAmount,
			ReloadCount,
			ZerocardAmount,
			ZerocardCount
		)
		SELECT
			@IdPosSettlement,
			t.c.value('ActivationAmount[1]', 'VARCHAR(200)'),
			t.c.value('ActivationCount[1]', 'VARCHAR(200)'),
			t.c.value('Amount[1]', 'VARCHAR(200)'),
			t.c.value('Count[1]', 'VARCHAR(200)'),
			t.c.value('RedemptionAmount[1]', 'VARCHAR(200)'),
			t.c.value('RedemptionCount[1]', 'VARCHAR(200)'),
			t.c.value('RefundAmount[1]', 'VARCHAR(200)'),
			t.c.value('RefundCount[1]', 'VARCHAR(200)'),
			t.c.value('ReloadAmount[1]', 'VARCHAR(200)'),
			t.c.value('ReloadCount[1]', 'VARCHAR(200)'),
			t.c.value('ZerocardAmount[1]', 'VARCHAR(200)'),
			t.c.value('ZerocardCount[1]', 'VARCHAR(200)')
		FROM @GiftTotal.nodes('/TerminalTotal/PosSettlementTerminalTotal') t(c)  

		SET @HasError = 0
		SET @Message = NULL
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @MSG_ERROR NVARCHAR(500) = ERROR_MESSAGE();

		SET @HasError = 1
		SET @Message = dbo.GetMessageFromMultiLenguajeResorces(1,'MESSAGE07')

		INSERT INTO ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage)
		VALUES('st_ConfirmPayment', GETDATE(), @MSG_ERROR);
	END CATCH

END

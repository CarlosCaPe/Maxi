/********************************************************************
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
	<log Date="03/08/2023" Author="jcsierra">Se agregan logs en status history</log>
</ChangeLog>
********************************************************************/
CREATE PROCEDURE [MoneyOrder].[st_CommitSaleRecord]
(
	@IdSaleRecord		INT,
	@TransCode			INT,

	@EnterByIdUser		INT,
	@IdLanguage			INT
)
AS
BEGIN
	DECLARE @MSG_ERROR NVARCHAR(500)

	BEGIN TRY
		DECLARE @IdSequenceStatusRecordDocument INT = 3,
				@IdSequence				INT,
				@TotalAmountToCorporate	MONEY,
				@AgentCommission		MONEY,
				@Sequence				BIGINT,
				@IdAgent				INT,
				@Description			VARCHAR(500),
				@IdStatusOpen			INT = 74
				
		SELECT 
			@IdSequence = sr.IdSequence,
			@IdAgent = sr.IdAgent,
			@Sequence = sr.SequenceNumber,
			@TotalAmountToCorporate = sr.TotalAmountToCorporate,
			@AgentCommission = sr.AgentCommission,
			@Description = CONCAT(sr.CustomerName, ' ', sr.CustomerFirstLastName)
		FROM MoneyOrder.SaleRecord sr WITH(NOLOCK)
		WHERE 
			sr.IdSaleRecord = @IdSaleRecord

		UPDATE MoneyOrder.SaleRecord SET
			IdStatus = @IdStatusOpen,
			TransCode = @TransCode
		WHERE IdSaleRecord = @IdSaleRecord

		UPDATE MoneyOrder.[Sequence] SET
			IdSequenceStatus = @IdSequenceStatusRecordDocument
		WHERE IdSequence = @IdSequence

		INSERT INTO MoneyOrder.SequenceDetail
		(
			IdSequence, 
			IdSequenceStatus, 
			CreationDate, 
			EnterByIdUser
		)
		VALUES
		(
			@IdSequence,
			@IdSequenceStatusRecordDocument,
			GETDATE(),
			@EnterByIdUser
		)

		-- INSERT IN BALANCE
		IF NOT EXISTS(SELECT 1 FROM AgentCurrentBalance WITH(NOLOCK) WHERE IdAgent = @IdAgent)
			INSERT INTO AgentCurrentBalance (IdAgent,Balance) VALUES (@IdAgent, 0)
		
		DECLARE	@Country	VARCHAR(200),
				@Balance	MONEY

		UPDATE AgentCurrentBalance SET 
			Balance = Balance + @TotalAmountToCorporate,
			@Balance= Balance + @TotalAmountToCorporate
		WHERE IdAgent=@IdAgent

		SELECT 
			@Country = c.CountryCode
		FROM Country c WITH(NOLOCK) 
		WHERE c.IdCountry = TRY_CAST(dbo.GetGlobalAttributeByName('IdCountryUSA') AS INT)

		INSERT INTO AgentBalance(
			IdAgent,        
			TypeOfMovement,        
			DateOfMovement,        
			Amount,        
			Reference,        
			Description,        
			Country,        
			Commission,  
			FxFee,        
			DebitOrCredit,        
			Balance,        
			IdTransfer        
			)        
		Values        
		(        
			@IdAgent,        
			'MO',        
			GETDATE(),        
			@TotalAmountToCorporate,        
			@Sequence,        
			@Description,        
			@Country,        
			@AgentCommission,  
			0,         
			'Debit',        
			@Balance,        
			@IdSaleRecord        
		)
		
		EXEC st_AgentVerifyCreditLimit @IdAgent
		EXEC MoneyOrder.st_ChangeMoneyOrderStatus @IdSaleRecord, NULL, 'Money Order Charge Added to Agent Balance', @EnterByIdUser, @IdLanguage

		SELECT 
			1 Success,
			dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericOkSave') [Message]
	END TRY
	BEGIN CATCH
		IF(ISNULL(@MSG_ERROR, '') = '')
			SET @MSG_ERROR = ERROR_MESSAGE();

		SELECT 
			0 Success,
			dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericErrorSave') [Message]

		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) 
		VALUES(ERROR_PROCEDURE() ,GETDATE(), @MSG_ERROR);
	END CATCH
END
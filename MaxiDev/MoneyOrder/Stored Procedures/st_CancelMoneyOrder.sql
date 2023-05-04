/********************************************************************
<Author>JCSierra</Author>
<Description></Description>

<ChangeLog>
<log Date="03/10/2023" Author="jcsierra">Create procedure</log>
</ChangeLog>
*********************************************************************/
CREATE   PROCEDURE MoneyOrder.st_CancelMoneyOrder
(
	@IdSaleRecord INT
)
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE 
		@IdAgent		INT,
		@DateOfMovement DATETIME,
		@Amount			MONEY,
		@Reference		INT,
		@Description	NVARCHAR(MAX),
		@Country		NVARCHAR(MAX),
		@Commission		MONEY,
		@Commission2	MONEY,
		@Balance		MONEY,
		@fxfee			MONEY,
		@IdCountry		INT

	SET @Balance=0
	SET @IdCountry = CAST(dbo.GetGlobalAttributeByName('IdCountryUSA') AS INT)

	SELECT
		@IdAgent = A.IdAgent,
		@DateOfMovement = GETDATE(),
		@Amount= (
			CASE
				WHEN a.CancelReturnCommission=1 THEN sr.TotalAmountToCorporate
				ELSE 
					CASE WHEN sr.TotalAmountToCorporate = sr.Amount + sr.FeeAmount THEN sr.Amount 
					ELSE sr.TotalAmountToCorporate -sr.CorporateCommission 
				END
			END
		),
		@Reference = sr.SequenceNumber,
		@Description= CONCAT(sr.CustomerName, ' ', sr.CustomerFirstLastName),
		@Country = C.CountryCode,
		@Commission= (
			CASE
				WHEN a.CancelReturnCommission = 1 THEN (sr.AgentCommission) * -1
			ELSE 
				CASE WHEN sr.TotalAmountToCorporate = sr.Amount + sr.FeeAmount 
					THEN sr.AgentCommission * -1 
					ELSE 0 
				END
			END
		)
	FROM MoneyOrder.SaleRecord sr WITH(NOLOCK)
		JOIN Agent a WITH(NOLOCK) on a.IdAgent = sr.IdAgent
		JOIN Country C WITH(NOLOCK) on c.IdCountry = @IdCountry
	WHERE sr.IdSaleRecord = @IdSaleRecord

	SELECT TOP 1 
		@Commission2= (Commission*-1), 
		@fxfee= (FxFee*-1) 
	FROM AgentBalance with(nolock) 
	WHERE 
		IdTransfer = @IdSaleRecord
		AND TypeOfMovement = 'MO'
	ORDER BY DateOfMovement DESC

	IF NOT EXISTS (SELECT 1 FROM AgentCurrentBalance WITH(NOLOCK) WHERE IdAgent=@IdAgent)
		INSERT INTO AgentCurrentBalance (IdAgent,Balance) VALUES (@IdAgent,@Balance)

	UPDATE AgentCurrentBalance SET 
		Balance= Balance - @Amount,
		@Balance = Balance - @Amount 
	WHERE IdAgent=@IdAgent

	INSERT INTO AgentBalance
	(
		IdAgent,
		TypeOfMovement,
		DateOfMovement,
		Amount,
		Reference,
		[Description],
		Country,
		Commission,
		FxFee,
		DebitOrCredit,
		Balance,
		IdTransfer
	)
	VALUES
	(
		@IdAgent,
		'MOVOID',
		@DateOfMovement,
		@Amount,
		@Reference,
		@Description,
		@Country,
		@Commission2,
		@fxfee,
		'Credit',
		@Balance,
		@IdSaleRecord
	);

	EXEC st_AgentVerifyCreditLimit @IdAgent;
END
CREATE   PROCEDURE [dbo].[st_BuildClaimCodeForTransfer]
(
	@IdGateway		INT,
	@IdPayer		INT,
	@IdPaymentType	INT,
	--@IdPayerConfig		INT,
	@ResultClaimCode	VARCHAR(50) OUT 
)
AS 
BEGIN
	SET @ResultClaimCode = ''
	CREATE TABLE #Result (Result NVARCHAR(MAX))	

	-- Validation duplicate claim
	DECLARE @Counter	INT = 0,
			@Limit		INT = 300
	WHILE @ResultClaimCode IS NULL 
		OR @Counter > @Limit
		OR 
		(
			EXISTS(SELECT 1 FROM Transfer t WITH(NOLOCK) WHERE t.ClaimCode = @ResultClaimCode)
			OR
			EXISTS(SELECT 1 FROM TransferClosed t WITH(NOLOCK) WHERE t.ClaimCode = @ResultClaimCode)
		)
	BEGIN
		SET @Counter = ISNULL(@Counter, 0) + 1

		IF ISNULL(@ResultClaimCode, '') = ''
		BEGIN
			IF @IdGateway IN (3, 10, 9, 8, 11, 13, 14, 15, 16, 18, 20, 22, 19, 24, 26, 28, 30, 31, 33, 35, 38, 42, 37)
			BEGIN
				DECLARE @PayerCode NVARCHAR(MAX)
				SELECT @PayerCode=PayerCode FROM Payer WITH(NOLOCK) WHERE IdPayer=@IdPayer  
  
				IF (@PayerCode='INMOB')--#1
					SET @PayerCode='MiCoope'
				IF (@PayerCode='MT' AND @IdPaymentType=6)
					SET @PayerCode='MiCoope'
				PRINT @PayerCode

				INSERT INTO #Result (Result)
				EXEC st_GenerateClaimCode @PayerCode; -- #MP1276

				SELECT TOP 1 @ResultClaimCode = LTRIM(RTRIM(Result)) FROM #Result
			END
			ELSE IF @IdGateway IN (39, 43, 44, 53, 40 /*46*/, 56, 55, 54, 51, 47, 34, 32, 4)
				EXEC GenerateClaimCodeByGateway @IdGateway, @ResultClaimCode OUT
			ELSE
				EXEC GenerateClaimCodeByGateway @IdGateway, @ResultClaimCode OUT
		END

		IF @IdGateway IN (53 /*46*/)
			SET @ResultClaimCode = CONCAT(
				@ResultClaimCode,
				'-',
				RIGHT(CONCAT('0000', FLOOR(RAND()*(10000))), 4)
			)
		ELSE IF @IdGateway = 32
			SET @ResultClaimCode = CONCAT(@ResultClaimCode, dbo.ApprizacheckDigit(@ResultClaimCode))
		ELSE IF @IdGateway = 4
			SET @ResultClaimCode = dbo.fn_DigitoVerificadorBTS(@ResultClaimCode)

		IF @Counter > @Limit
		BEGIN
			SET @ResultClaimCode = NULL
			SELECT 1/0
			RETURN
		END
	END
END

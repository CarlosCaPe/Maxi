CREATE PROCEDURE [dbo].[st_FetchPayer]
(
	@Name	   			VARCHAR(200)=NULL,
	@IdPaymentType	    INT = NULL,
	@IdCountry	        INT = NULL,
	@ShowDisabled	    BIT = 0,
	@Offset			    BIGINT,
	@Limit			    BIGINT
)
AS
BEGIN
	DECLARE @Records TABLE (Id INT, _PagedResult_Total BIGINT)
IF (@ShowDisabled=1)
BEGIN

	INSERT INTO @Records(Id, _PagedResult_Total)
	SELECT
		cc.IdPayer,
		COUNT(*) OVER() _PagedResult_Total
	FROM Payer cc WITH(NOLOCK)
	JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayer = cc.IdPayer
	JOIN PaymentType pk WITH(NOLOCK) ON pk.IdPaymentType = pc.IdPaymentType
	JOIN CountryCurrency pp WITH(NOLOCK) ON pp.IdCountryCurrency = pc.IdCountryCurrency
	JOIN Country py WITH(NOLOCK) ON py.IdCountry = pp.IdCountry
	WHERE 
		(@Name IS NULL OR cc.PayerName LIKE CONCAT('%', @Name, '%')) -- @Name
		AND (@IdPaymentType IS NULL OR (pk.IdPaymentType = @IdPaymentType AND pc.IdPaymentType=@IdPaymentType )) -- @IdPaymentType
		AND (@IdCountry IS NULL OR (py.IdCountry = @IdCountry AND pp.IdCountry=@IdCountry )) -- @IdCountry
	ORDER BY cc.IdPayer
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
ELSE 
BEGIN
 INSERT INTO @Records(Id, _PagedResult_Total)
	SELECT
		cc.IdPayer,
		COUNT(*) OVER() _PagedResult_Total
	FROM Payer cc WITH(NOLOCK)
	JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayer = cc.IdPayer
	JOIN PaymentType pk WITH(NOLOCK) ON pk.IdPaymentType = pc.IdPaymentType
	JOIN CountryCurrency pp WITH(NOLOCK) ON pp.IdCountryCurrency = pc.IdCountryCurrency
	JOIN Country py WITH(NOLOCK) ON py.IdCountry = pp.IdCountry
	WHERE 
		cc.IdGenericStatus=1
		AND (@Name IS NULL OR cc.PayerName LIKE CONCAT('%', @Name, '%')) -- @Name
		AND (@IdPaymentType IS NULL OR (pk.IdPaymentType = @IdPaymentType AND pc.IdPaymentType=@IdPaymentType )) -- @IdPaymentType
		AND (@IdCountry IS NULL OR (py.IdCountry = @IdCountry AND pp.IdCountry=@IdCountry )) -- @IdCountry
	ORDER BY cc.IdPayer
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END

SELECT DISTINCT
		cc.IdPayer, 
		cc.PayerName, 
		cc.PayerCode, 
		cc.IdGenericStatus,
		cc.DateOfLastChange, 
		cc.EnterByIdUser,
		r._PagedResult_Total
	FROM Payer cc WITH(NOLOCK)
		JOIN @Records r ON r.Id = cc.IdPayer

	SELECT
		pc.IdPayerConfig,
		pc.IdPayer,
		pc.IdGateway,
		pc.IdPaymentType,
		pc.IdCountryCurrency,
		pc.IdGenericStatus,
		pc.SpreadValue,
		pc.DateOfLastChange,
		pc.EnterByIdUser,
		pc.DepositHold,
		pc.RequireBranch,
		pc.EnabledSchedule,
		pc.StartTime,
		pc.EndTime
	FROM PayerConfig pc WITH(NOLOCK)
		JOIN @Records r ON r.Id = pc.IdPayer
END
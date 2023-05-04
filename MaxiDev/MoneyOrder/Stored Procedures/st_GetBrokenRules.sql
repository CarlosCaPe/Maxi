CREATE   PROCEDURE [MoneyOrder].[st_GetBrokenRules]
(
	@IdSaleRecord INT,
	@IdLanguage INT = NULL
)
AS 
BEGIN 
	
	SELECT ka.IdKYCAction,  
		IIF(@IdLanguage = 1, br.MessageInEnglish, br.MessageInSpanish) AS 'Notification', 
		ka.[Action], 
		k.RuleName, 
	 	IIF(@IdLanguage = 1, k.MessageInEnglish, k.MessageInSpanish) AS 'KYCRuleDetail' 
	FROM KYCRule k WITH(NOLOCK)
	INNER JOIN KYCAction ka WITH(NOLOCK) ON k.[Action] = ka.IdKYCAction 
	INNER JOIN MoneyOrder.SaleRecordBrokenRules br WITH(NOLOCK) ON k.IdRule = br.IdRule 
	WHERE br.IdSaleRecord = @IdSaleRecord

END

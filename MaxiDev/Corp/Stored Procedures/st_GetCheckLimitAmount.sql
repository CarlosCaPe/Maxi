CREATE PROCEDURE [Corp].[st_GetCheckLimitAmount]
AS
BEGIN

	SELECT * 
	FROM GlobalAttributes WITH(nolock) 
	WHERE [name] = 'CheckLimitAmountPerCustomer'
	UNION	
	SELECT * 
	FROM GlobalAttributes WITH(nolock) 
	WHERE [name] = 'MaxAmountForcheck'

END






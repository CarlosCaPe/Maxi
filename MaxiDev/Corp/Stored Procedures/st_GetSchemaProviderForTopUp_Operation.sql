CREATE procedure [Corp].[st_GetSchemaProviderForTopUp_Operation]
AS
	SELECT
		[IdProvider]
		, [ProviderName]
	FROM [dbo].[Providers] WITH (NOLOCK)
	WHERE [IdProvider] IN (2,3,5)
	ORDER BY [ProviderName]

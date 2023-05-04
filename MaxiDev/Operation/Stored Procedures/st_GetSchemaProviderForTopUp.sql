-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-22
-- Description:	Returns providers for top up business // this stored is used in search other products and Top up schemes (Backoffice-Corporate)
-- =============================================
CREATE PROCEDURE [Operation].[st_GetSchemaProviderForTopUp]
AS
	SELECT
		[IdProvider]
		, [ProviderName]
	FROM [dbo].[Providers] WITH (NOLOCK)
	WHERE [IdProvider] IN (2,3,5)
	ORDER BY [ProviderName]

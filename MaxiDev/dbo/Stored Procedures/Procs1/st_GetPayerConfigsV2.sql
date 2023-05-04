CREATE PROCEDURE [dbo].[st_GetPayerConfigsV2] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT P.[PayerName], P.[IdPayer], P.[PayerCode], P.[Folio], P.[IdGenericStatus], P.[DateOfLastChange], P.[EnterByIdUser], P.[PayerLogo]
    FROM [dbo].[payerconfig] AS PC WITH(NOLOCK)
		INNER JOIN Payer AS P WITH(NOLOCK) ON PC.IdPayer = P.IdPayer
	WHERE PC.IdGenericStatus = 1

END




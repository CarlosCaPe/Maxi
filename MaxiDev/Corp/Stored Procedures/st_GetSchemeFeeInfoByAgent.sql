CREATE PROCEDURE [Corp].[st_GetSchemeFeeInfoByAgent]
	-- Add the parameters for the stored procedure here
	@IdAgent INT,
	@IdLenguage INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	[AS].[IdAgentSchema]
	,[AS].[SchemaName]
	,ISNULL([ASD].[IdFee], [AS].[IdFee]) IdFee
	,[P].[IdPayer]
	,[P].[PayerName]
	,[dbo].[GetMessageFromMultiLenguajeResorces] (
	   @IdLenguage
	  , CONCAT('PAYMENTTYPE',CONVERT(NVARCHAR(MAX),(CASE [PC].[IdPaymentType] WHEN 4 THEN 1 ELSE [PC].[IdPaymentType] END)))) [PaymentName],
	  CASE [PC].[IdPaymentType] WHEN 4 THEN 1 ELSE [PC].[IdPaymentType] END [IdPaymentType],
	  [CC].IdCountry
	FROM [dbo].[AgentSchema] [AS] (NOLOCK)
	JOIN [dbo].[CountryCurrency] [CC] (NOLOCK) on [CC].[IdCountryCurrency]=[AS].[IdCountryCurrency]
	JOIN [dbo].[AgentSchemaDetail] [ASD] (NOLOCK) ON [AS].[IdAgentSchema] = [ASD].[IdAgentSchema]
	JOIN [dbo].[PayerConfig] [PC] (NOLOCK) ON [ASD].[IdPayerConfig] = [PC].[IdPayerConfig]
	JOIN [dbo].[Payer] [P] (NOLOCK) ON [PC].[IdPayer] = [P].[IdPayer]
	WHERE [AS].[IdAgent] = @IdAgent AND 
	[AS].[IdGenericStatus] = 1 AND [PC].IdGenericStatus = 1 AND [P].[IdGenericStatus] = 1
	ORDER BY [AS].[SchemaName], [P].[PayerName]

END

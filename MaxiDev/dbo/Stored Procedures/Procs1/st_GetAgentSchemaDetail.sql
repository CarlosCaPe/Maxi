
CREATE PROCEDURE [dbo].[st_GetAgentSchemaDetail]
(
	@IdAgentSchema INT
)
AS

	DECLARE @CurrentDate DATETIME=GETDATE()
	
	SELECT 
		IdAgentSchemaDetail,IdPayerConfig,PayerConfigSpread,IdPayer,PayerName,PayerCode,IdPaymentType,PaymentName,IdCountry,CountryName,CountryCode,IdCurrency,CurrencyCode,CurrencyName,IdCountryCurrency,DateOfLastChange,EnterByIdUser,ExchangeRate,IdCommission,CommissionName,IdFee,FeeName,TempSpread,EndDateTempSpread,SpreadValue,IdSpread,SpreadName
		,CASE 
				WHEN ISNULL(IdSpread,0)>0 THEN 
					convert(varchar(max),ExchangeRate)+'*'
				ELSE 
					convert(varchar(max),ISNULL([dbo].[FunCurrentExRate](IdCountryCurrency,IdGateway,IdPayer,IdAgent,NULL,IdPaymentType,IdAgentSchema,1),ExchangeRate))
		  END
		  RealExchangeRate		
		FROM (

		SELECT ASD.IdAgentSchemaDetail
		, ASD.IdPayerConfig
		,PC.SpreadValue PayerConfigSpread
		, PC.IdPayer 
		, P.PayerName
		, P.PayerCode 
		, PC.IdPaymentType  
		, PT.PaymentName
		, CO.IdCountry 
		, CO.CountryName 
		, CO.CountryCode
		, CU.IdCurrency 
		, CU.CurrencyCode 
		, CU.CurrencyName
		, PC.IdCountryCurrency
		, ASD.DateOfLastChange
		, ASD.EnterByIdUser
		, [dbo].[FunRefExRate](PC.IdCountryCurrency ,PC.IdGateway ,PC.IdPayer) ExchangeRate
		, ASD.IdCommission
		, C.CommissionName 
		, ASD.IdFee
		, F.FeeName 
		, CASE WHEN ISNULL(ASD.EndDateTempSpread,'19000101') < @CurrentDate THEN NULL ELSE ASD.TempSpread END TempSpread
		, CASE WHEN ISNULL(ASD.EndDateTempSpread,'19000101') < @CurrentDate THEN NULL ELSE ASD.EndDateTempSpread END EndDateTempSpread
		, ASD.SpreadValue
		, ASD.IdSpread
		, S.SpreadName	
		, PC.IdGateway
		, AGS.IdAgent
		, ASD.IdAgentSchema
		FROM AgentSchemaDetail ASD (NOLOCK)
			inner JOIN AgentSchema AGS (NOLOCK) ON ASD.IdAgentSchema = AGS.IdAgentSchema
			inner JOIN PayerConfig PC (NOLOCK) ON ASD.IdPayerConfig = PC.IdPayerConfig
			inner JOIN Payer P (NOLOCK) ON PC.IdPayer = P.IdPayer 
			inner JOIN PaymentType PT (NOLOCK) ON PC.IdPaymentType = PT.IdPaymentType
			inner JOIN CountryCurrency CC (NOLOCK) ON PC.IdCountryCurrency = CC.IdCountryCurrency
			inner JOIN Country CO (NOLOCK) ON CC.IdCountry = CO.IdCountry 
			inner JOIN Currency CU (NOLOCK) ON CC.IdCurrency = CU.IdCurrency 
			left JOIN Fee F (NOLOCK) ON ASD.IdFee = F.IdFee 
			left JOIN Commission C (NOLOCK) ON ASD.IdCommission = C.IdCommission 
			left JOIN Spread S (NOLOCK) ON ASD.IdSpread = S.IdSpread
		WHERE ASD.IdAgentSchema=@IdAgentSchema --and pc.IdGenericStatus = 1
	) t
	ORDER BY 4,7

CREATE PROCEDURE [Corp].[st_GetAgentSchemaById]
(
	@idAgentSchema int
)
as
begin
	Declare @idFee int, @idCommission int

	--Guardo los valores en las variables para los demas datos
	Select @idFee = IdFee, @idCommission = IdCommission from AgentSchema with (NOLOCK) where IdAgentSchema=@idAgentSchema

	--Obtiene los datos de la tabla Agent Schema
	SELECT A.IdAgentSchema, A.SchemaName, A.IdCountryCurrency, CO.CountryName, CU.CurrencyName, A.SchemaDefault,
	A.DateOfLastChange, A.IdGenericStatus, GS.GenericStatus, A.Description, A.IdFee, F.FeeName, A.IdCommission, C.CommissionName
	FROM AgentSchema A with (NOLOCK)
		JOIN CountryCurrency CC with (NOLOCK) ON A.IdCountryCurrency =CC.IdCountryCurrency
		JOIN Country CO with (NOLOCK) ON CC.IdCountry =CO.IdCountry 
		JOIN Currency CU with (NOLOCK) ON CC.IdCurrency =CU.IdCurrency
		JOIN GenericStatus GS with (NOLOCK) ON A.IdGenericStatus = GS.IdGenericStatus    
		left JOIN Fee F with (NOLOCK) On F.IdFee=A.IdFee
		left JOIN Commission C with (NOLOCK) ON C.IdCommission=A.IdCommission
	WHERE A.IdAgentSchema=@IdAgentSchema

	--Obtiene los datos de la tabla CommissionDetails
	Select IdCommissionDetail, AgentCommissionInPercentage, CorporateCommissionInPercentage, FromAmount, ToAmount, ExtraAmount
	from CommissionDetail with (NOLOCK)
	where IdCommission = @IdCommission

	--Obtiene los datos de la tabla FeeDetails
    SELECT [IdFeeDetail], [FromAmount], [ToAmount], [Fee] 
	FROM [dbo].[FeeDetail] with (NOLOCK)
	WHERE [IdFee] = @IdFee

	--Obtiene los datos de la tabla AgentSchemaDetail
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
		SELECT ASD.IdAgentSchemaDetail, ASD.IdPayerConfig, PC.SpreadValue PayerConfigSpread, PC.IdPayer, P.PayerName, P.PayerCode, 
		PC.IdPaymentType, PT.PaymentName, CO.IdCountry, CO.CountryName, CO.CountryCode, CU.IdCurrency, CU.CurrencyCode,
		CU.CurrencyName, PC.IdCountryCurrency, ASD.DateOfLastChange, ASD.EnterByIdUser
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
		FROM AgentSchemaDetail ASD with (NOLOCK)
			inner JOIN AgentSchema AGS with (NOLOCK) ON ASD.IdAgentSchema = AGS.IdAgentSchema
			inner JOIN PayerConfig PC with (NOLOCK) ON ASD.IdPayerConfig = PC.IdPayerConfig
			inner JOIN Payer P with (NOLOCK) ON PC.IdPayer = P.IdPayer 
			inner JOIN PaymentType PT with (NOLOCK) ON PC.IdPaymentType = PT.IdPaymentType
			inner JOIN CountryCurrency CC with (NOLOCK) ON PC.IdCountryCurrency = CC.IdCountryCurrency
			inner JOIN Country CO with (NOLOCK) ON CC.IdCountry = CO.IdCountry 
			inner JOIN Currency CU with (NOLOCK) ON CC.IdCurrency = CU.IdCurrency 
			left JOIN Fee F with (NOLOCK) ON ASD.IdFee = F.IdFee 
			left JOIN Commission C with (NOLOCK) ON ASD.IdCommission = C.IdCommission 
			left JOIN Spread S with (NOLOCK) ON ASD.IdSpread = S.IdSpread
		WHERE ASD.IdAgentSchema=@IdAgentSchema --and pc.IdGenericStatus = 1
	) t
	--ORDER BY 4,7
	ORDER BY IdPayer, IdPaymentType
end

CREATE PROCEDURE [dbo].[st_GetAgentSchema]
(
	@IdAgentSchema INT
)
AS
	
	SELECT A.IdAgentSchema  
	, A.SchemaName
	, A.IdCountryCurrency
	, CO.CountryName
	, CU.CurrencyName
	, A.SchemaDefault
	, A.DateOfLastChange
	, A.IdGenericStatus
	, GS.GenericStatus 
	, A.Description
	,A.IdFee
	,F.FeeName
	,A.IdCommission
	,C.CommissionName
	FROM AgentSchema A (NOLOCK)
		JOIN CountryCurrency CC (NOLOCK) ON A.IdCountryCurrency =CC.IdCountryCurrency
		JOIN Country CO (NOLOCK) ON CC.IdCountry =CO.IdCountry 
		JOIN Currency CU (NOLOCK) ON CC.IdCurrency =CU.IdCurrency
		JOIN GenericStatus GS (NOLOCK) ON A.IdGenericStatus = GS.IdGenericStatus    
		left JOIN Fee F (NOLOCK) On F.IdFee=A.IdFee
		left JOIN Commission C (NOLOCK) ON C.IdCommission=A.IdCommission
	WHERE A.IdAgentSchema=@IdAgentSchema

	

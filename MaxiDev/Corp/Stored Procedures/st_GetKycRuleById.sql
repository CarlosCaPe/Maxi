CREATE procedure [Corp].[st_GetKycRuleById]
(
	@IdRule int
)
as
SET NOCOUNT ON;
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="17/02/2017" Author="jmoreno">Se agrega el IdState para el guardado de la KYC</log>
<log Date="29/06/2017" Author="snevarez">Se agrega el IdStateDestination para el guardado de la KYC y usarlo en la aplicacion de reglas por estado destino</log>
<log Date="16/08/2017" Author="mdelgado">Add New Columns S35</log>
</ChangeLog>
********************************************************************/
SELECT 
	K.[IdRule]
	,K.[RuleName]
	,K.[IdPayer]
	,K.[IdPaymentType]
	,K.[Actor]
	,K.[Symbol]
	,K.[Amount]
	,K.[AgentAmount]
	,K.[IdCountryCurrency]
	,K.[TimeInDays]
	,K.[Action]
	,K.[MessageInSpanish]
	,K.[MessageInEnglish]
	,K.[IdGenericStatus]
	,K.[DateOfLastChange]
	,K.[EnterByIdUser]
	,K.[IdAgent]
	,K.[IdCountry]
	,K.[IdGateway]
	,K.[Factor]
	,K.[SSNRequired]
	,K.[OccupationRequired]
	,K.[IsConsecutive]
	,K.[Transactions]
	,K.[IsExpire]
	,K.[ExpirationDate]
	,K.[Creationdate]
	,K.[ComplianceFormatId]
	,P.[PayerName]
	,CONCAT(A.[AgentCode], ' ', A.[AgentName]) 'Agentname'
	, K.IdState
	, K.IdStateDestination /*S28*/
	/*>> s35*/
	, K.IdTypeRequired
	, K.IdNumberRequired
	, K.IdExpirationDateRequired
	, K.IdStateCountryRequired
	, K.DateOfBirthRequired
	/*<< s35*/
FROM [dbo].[KYCRule] K (NOLOCK)
LEFT JOIN [dbo].[Payer] P (NOLOCK) ON K.[IdPayer] = P.[IdPayer]
LEFT JOIN [dbo].[Agent] A (NOLOCK) ON K.[IdAgent] = A.[IdAgent]
--LEFT JOIN [dbo].[ComplianceFormat] CF (NOLOCK) ON K.[ComplianceFormatId] = CF.ComplianceFormatId
WHERE K.[IdRule] = @IdRule


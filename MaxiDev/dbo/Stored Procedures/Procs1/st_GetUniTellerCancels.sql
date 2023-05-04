
CREATE procedure [dbo].[st_GetUniTellerCancels]    
as    
Set Nocount on

Select
Trans.ClaimCode							AS txIdentifier,
Trans.ClaimCode							AS correspondentRefNumber,
Trans.IdAgent							AS operator,
Agen.AgentCode						    AS txAgentCode,
'099'								    AS txCancelType, --099 Other
FORMAT(GETDATE(), 'MMddyyyyHHmmss')		AS processingDateLocal,
Trans.Fee								AS cancellationFee,
''										AS reserved1,
''										AS reserved2,
''										AS reserved3
from [dbo].[Transfer] Trans
INNER JOIN [dbo].[CountryCurrency] CoCurrency 
	on Trans.IdCountryCurrency = CoCurrency.IdCountryCurrency
INNER JOIN [dbo].[Country] Coun 
	on CoCurrency.IdCountry = Coun.IdCountry
INNER JOIN [dbo].[Currency] Curr 
	on CoCurrency.IdCurrency = Curr.IdCurrency
INNER JOIN [dbo].[Agent] Agen 
	on Trans.IdAgent = Agen.IdAgent
INNER JOIN [dbo].[Payer] Pay 
	on Trans.IdPayer = Pay.IdPayer
INNER JOIN [dbo].[PaymentType] PaTy 
	on Trans.IdPaymentType = PaTy.IdPaymentType
LEFT JOIN [dbo].[CustomerIdentificationType] CusIdType 
	on Trans.CustomerIdCustomerIdentificationType = CusIdType.IdCustomerIdentificationType
Where IdGateway=22 and IdStatus=25

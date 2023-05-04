CREATE procedure [dbo].[st_GetCorporacionesUnidasCancels]    
as    
Set Nocount on

Select
600							as idRemesadora,
Trans.ClaimCode				AS nroGuia,
Trans.IdTransfer			AS correspondentRefNumber
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
Where IdGateway=47 and IdStatus=25

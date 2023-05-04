CREATE Procedure [dbo].[st_GetCorporacionesUnidas]                            
AS                            
Set nocount on  

--- Get Minutes to wait to be send to service ---                            
Declare @MinutsToWait Int                            
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'   
--set @MinutsToWait=5  

---  Update transfer to Attempt -----------------                            
Select top 300 IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=47 and  IdStatus=20 /*---*/                         
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                              
--------- Tranfer log ---------------------------                        
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                         
Select 21,IdTransfer,GETDATE() from #temp                            

Select 
K.GatewayBranchCode idAgencia,--ID de la Agencia de CORPOAUSTRO a la cual está destinado el giro
600 idRemesadora, --ID único Asignado por CORPOAUSTRO para la Remesadora
ClaimCode nroGuia, --ID Secuencial único aceptado por CORPOAUSTRO y generado por la remesadora para identificar internamente un giro
IdTransfer nroOrden,--Nro de orden interno manejado por la Remesadora
A.Folio nroReferencia, --Nro de Referencia interno manejado por la Remesadora
'' nroClave, -- Nro de Clave interno manejado por la Remesadora
A.DateOfTransfer fechaGiro, --Fecha de Generación del Giro en el Sistema de la Remesadora
A.IdCountryCurrency idRemitente, --ID del Remitente
E.Name tipoIDRemitente, --Tipo de ID: CEDULA, PASAPORTE,LICENCIA, ETC
Cu.Name + ' ' + cu.FirstLastName + ' ' + cu.SecondLastName remitente, --Nombre del Remitente
Cu.CelullarNumber telefonoRemitente, --Telefono del Remitente
Cu.Address direccionRemitente, --Direccion del Remitente
(Select City from Customer with(nolock) where IdCustomer = A.IdCustomer) ciudadRemitente, --Ciudad del Remitente
(Select State from Customer with(nolock) where IdCustomer = A.IdCustomer) estadoRemitente, --Estado del Remitente
(Select Zipcode from Customer with(nolock) where IdCustomer = A.IdCustomer) codigoPostalRemitente, --Codigo Postal del Remitente
(Select Country from Customer with(nolock) where IdCustomer = A.IdCustomer) paisRemitente, --Pais del Remitente
A.BeneficiaryName + ' ' + A.BeneficiaryFirstLastName + ' ' + A.BeneficiarySecondLastName Beneficiario, --Nombre del Beneficiario
A.BeneficiaryPhoneNumber telefonoBeneficiario, --Telefono del Bneficiario
A.BeneficiaryAddress direccionBeneficiario, --Direccion del Beneficiario
A.BeneficiaryCity ciudadBeneficiario, -- Ciudad del Beneficiario
A.BeneficiaryState estadoBeneficiario, --Estado del Beneficiario
A.BeneficiaryZipcode codigoPostalBeneficiario, --Codigo Postal del Beneficiario
A.BeneficiaryCountry paisBeneficiario, --Pais del Beneficiario
A.AmountInDollars montoGiro, --Monto del Giro
A.AgentCommission Comision, --Comision del giro
Curr.CurrencyCode Moneda,--Abreviación de la Moneda de Origen. Ej. USD
A.ExRate tipoCambio, --Factor de conversión entre monedas de origen y destino, si son las mismas colocar 1
'' Instrucciones,
'' mensaje
from Transfer A with(nolock)
INNER JOIN [dbo].[CountryCurrency] CoCurrency on A.IdCountryCurrency = CoCurrency.IdCountryCurrency
INNER JOIN [dbo].[Currency] Curr on CoCurrency.IdCurrency = Curr.IdCurrency
INNER JOIN [dbo].Payer p on A.idpayer = p.idpayer
INNER JOIN Customer Cu ON Cu.IdCustomer = A.IdCustomer
Left Join CustomerIdentificationType E on (E.IdCustomerIdentificationType=A.CustomerIdCustomerIdentificationType) 
Join Agent C On (A.IdAgent=C.IdAgent)
Join Country F on (F.IdCountry=CoCurrency.IdCountry)
Join Branch G on (A.IdBranch=G.IdBranch)  
Join City H on (G.IdCity=H.IdCity)
Join State I on (H.IdState=I.IdState)
join GatewayBranch K on K.IdBranch = A.IdBranch
Join Currency J on (J.IdCurrency=Curr.IdCurrency) 
left join [BeneficiaryIdentificationType] benid on benid.IdBeneficiaryIdentificationType=A.IdBeneficiaryIdentificationType
left join CountryExrateConfig cex on CoCurrency.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=A.idgateway
WHERE A.IdGateway = 47 
AND A.IdStatus = 21
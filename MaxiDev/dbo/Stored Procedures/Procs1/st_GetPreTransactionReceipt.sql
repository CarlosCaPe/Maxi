
CREATE PROCEDURE [dbo].[st_GetPreTransactionReceipt]
(
	@IdTransfer			INT,
	@IdCountryOrigin	INT,
	@IdCountryDestiny	INT
)
AS

/********************************************************************
<Author> ??? </Author>
<app> Agent, Corporative </app>
<Description> Gets print information for Tickets and PreRecepits</Description>

<ChangeLog>
<log Date="02/10/2017" Author="jmoreno">California Disclamer.</log>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="11/11/2021" Author="saguilar">Add Coversion LocalTime by Agent</log>
<log Date="26/11/2021" Author="saguilar">Add Coversion LocalTime by Agent</log>
<log Date="24/01/2022" Author="jcsierra">Add PosTransfer props</log>
<log Date="11/05/2022" Author="jcsierra">Add OtherFeeMN Column</log>
<log Date="24/04/2023" Author="maprado" name="">BM-1678 - Format Sp</log>
<log Date="24/04/2023" Author="maprado" name="">BM-1678 - Se agrega logica para tomar en cuenta tabla PreTransferClosed</log>
</ChangeLog>

*********************************************************************/      
SET NOCOUNT ON;  
      

--jmoreno
DECLARE @BoldDisclamerStates Table (AgentState VARCHAR(10))
INSERT INTO  @BoldDisclamerStates VALUES ('CA')      
      
declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');

--get lenguage resource
declare @lenguage1 int
declare @lenguage2 int

select @lenguage1=idlenguage from countrylenguage with(nolock) where idcountry=@IdCountryOrigin
if @lenguage1 is null
begin    
    select @lenguage1=idlenguage from countrylenguage with(nolock) where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryUSA'))
end

select @lenguage2=idlenguage from countrylenguage with(nolock) where idcountry=@IdCountryDestiny
if @lenguage2 is null
begin    
    select @lenguage2=idlenguage from countrylenguage with(nolock) where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryMexico'))
end 
 
declare @PreTransferEnglishMessage varchar(max)      
declare @PreTransferSpanishMessage varchar(max)
--disclaimers
declare @DisclaimerES01 nvarchar(max)
declare @DisclaimerES02 nvarchar(max)
declare @DisclaimerES03 nvarchar(max)
declare @DisclaimerES07 nvarchar(max)
declare @DisclaimerEN01 nvarchar(max)
declare @DisclaimerEN02 nvarchar(max)
declare @DisclaimerEN03 nvarchar(max)
declare @DisclaimerEN07 nvarchar(max)

DECLARE @PreReceiptDisclaimerEN nvarchar(max),
		@PreReceiptDisclaimerES nvarchar(max)


select @PreTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'PreTransferMessage'),
       @PreTransferSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'PreTransferMessage'),
       @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1'),
       @DisclaimerEN02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer2'),
       @DisclaimerEN03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer3'),
	   @DisclaimerEN07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer7'),

       @DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer1'),
       @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer2'),
       @DisclaimerES03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer3'),
	   @DisclaimerES07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer7')
       
 
Declare @IdCountryCurrencyMexicoPesos int= [dbo].[GetGlobalAttributeByName]('IdCountryCurrencyMexicoPesos')

Declare @Resend bit  
Set @Resend=1  
Declare @NotResend bit  
Set @NotResend=0  
Declare @ComprobanteMessage int 
set @ComprobanteMessage=0
 
		set @ComprobanteMessage = ISNULL((select top 1 1 from BrokenRulesByTransfer with(nolock) where IdTransfer=@IdTransfer and IdKYCAction=4 and MessageInSpanish like '%comprobante de ingresos%' ),'')



--- Conversion Hora Local Pretransfer

	Declare @receiptType bit = 1

	Select DateOfTransferLocal,
		PrintedDate,
		TimeZone

	into #LocalTime                       
	from [dbo].[FnConvertLocalTimeZone] (@IdTransfer,@receiptType) -- Se invoca Funcion Timezone
		
	Declare @LocalDate datetime,
			@PrintedDate datetime,
			@TimeZone nvarchar(3)

	select @LocalDate=DateOfTransferLocal,
	        @TimeZone=TimeZone,
			@PrintedDate=PrintedDate
	from #LocalTime
		
	Drop table #LocalTime
				
	DECLARE @IdCountryUSA	INT,
			@IdCurrencyUSA	INT
	SET @IdCountryUSA = dbo.GetGlobalAttributeByName('IdCountryUSA')
	SET @IdCurrencyUSA = dbo.GetGlobalAttributeByName('IdCurrencyUSA')
--- Termina Conversion

	DECLARE @HideCityAndStatePaymentType TABLE (Id INT) 
	INSERT INTO @HideCityAndStatePaymentType
	VALUES (2)

	IF EXISTS(SELECT 1 FROM PreTransfer WITH (NOLOCK) WHERE IdPreTransfer = @IdTransfer)    
	BEGIN
		SELECT       
			@CorporationPhone CorporationPhone,      
			@CorporationName CorporationName,    
			@PreTransferEnglishMessage PreTransferEnglishMessage,
			@PreTransferSpanishMessage PreTransferSpanishMessage,  
			A.AgentCode + ' ' + A.AgentName AgentName,      
			A.AgentAddress,      
			A.AgentCity + ' ' + A.AgentState + ' ' + REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AgentLocation,
			A.AgentPhone,      
			T.Folio,       
			U.UserLogin,      
			@LocalDate as DateOfPreTransfer,
			T.IdCustomer,      
			T.CustomerName + ' ' + T.CustomerFirstLastName + ' ' + T.CustomerSecondLastName CustomerFullName,      
			T.CustomerAddress,      
			T.CustomerCity + ' ' + T.CustomerState + ' ' + REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') AS  CustomerLocation,      
			T.CustomerPhoneNumber,  
			T.CustomerCelullarNumber,
			CASE
				WHEN T.CustomerIdCarrier <> 0 THEN 'YES'
				ELSE 'NO'
			END AS CustomerReceiveMessage,    
			T.BeneficiaryName + ' ' + T.BeneficiaryFirstLastName + ' ' + T.BeneficiarySecondLastName BeneficiaryFullName,      
			T.BeneficiaryAddress,      
			CASE
				WHEN T.BeneficiaryCity = '' THEN BrC.CityName + ' ' + BrS.StateName + ' ' + Br.zipcode    
				ELSE B.City + ' ' + B.[State] + ' ' + B.Zipcode     
			END AS BeneficiaryLocation,      
			T.BeneficiaryPhoneNumber,    
			T.BeneficiaryCountry,    
			Py.PaymentName,      
			T.AmountInDollars,      
			T.Fee - T.Discount Fee,      
			T.ExRate,      
			P.PayerName,      
			GB.GatewayBranchCode,      
			CASE
				WHEN CCu.CurrencyCode = 'MXP' THEN 'MXN' 
				WHEN (CC.IdCountry = @IdCountryUSA) THEN 'US'
				ELSE CCu.CurrencyCode 
			END AS CurrencyCode,     
			T.AmountInMN,      
			0.0 OtherFeeMN,
			CCo.CountryName + ' ' + CCu.CurrencyName CountryCurrency,      
			T.DepositAccountNumber,      
			Br.BranchName,  
			CASE 
				WHEN EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) THEN CCo.CountryName
				WHEN ISNULL(BrS.StateName, '') = '' THEN CCo.CountryName
				ELSE CONCAT(BrC.CityName, ' ', BrS.StateName, ', ', CCo.CountryName)
			END AS BranchLocation,  
			ISNULL(CASE a.Agentstate
				WHEN 'OK' THEN 'Oklahoma' 
				WHEN NULL THEN '' 
				ELSE a.Agentstate
			END,'') StateTax,
			ISNULL(t.statetax,dbo.fn_getStateTaxFromTransfer(@IdTransfer)) AS Tax,
			@ComprobanteMessage as ComprobanteMessage,
			@DisclaimerES01 DisclaimerES01,
			@DisclaimerEn01 DisclaimerEn01,
			@DisclaimerES02 DisclaimerES02,
			@DisclaimerEn02 DisclaimerEn02,
			@DisclaimerES03 DisclaimerES03,
			@DisclaimerEn03 DisclaimerEn03,
			CASE
				WHEN T.IdGateway = 4 AND T.IdPaymentType IN (1,4) and T.IdCountryCurrency = @IdCountryCurrencyMexicoPesos and T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars*T.ExRate,2) THEN '*** ' + @DisclaimerEN07 + '.'
				ELSE ''
			END DisclaimerEn07,
			CASE
				WHEN T.IdGateway = 4 AND T.IdPaymentType IN (1,4) AND T.IdCountryCurrency = @IdCountryCurrencyMexicoPesos AND T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars*T.ExRate,2) THEN '*** ' + @DisclaimerEs07 + '.'
				ELSE ''
			END DisclaimerEs07,
			'' AccountTypeName, --AT.[AccountTypeName],
			report.HTML_JUSTIFY(@DisclaimerEn01 + '*** '+ @DisclaimerEn02 + '*** '+ @DisclaimerEn03 + @DisclaimerEN07,
			61, 'Consolas', 7,0,0) AS EngMessPreReceipt,
			report.HTML_JUSTIFY(@DisclaimerES01 + '*** '+ @DisclaimerES02 + '*** '+ @DisclaimerES03 + @DisclaimerES07,
			61, 'Consolas', 7,0,0) AS SpaMessPreReceipt 
			, EmphasizedDisclamer = Convert(BIT,CASE WHEN A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN 1 ELSE 0 END)
			, BeneficiaryMirrorFullName = NULL
			, BeneficiaryMirrorAddress = NULL
			, BeneficiaryMirrorLocation = NULL
			, BeneficiaryMirrorPhoneNumber = NULL
			, BeneficiaryMirrorCountry = NULL
			, @PrintedDate AS PrintedDate
			, @TimeZone AS TimeZoneAbbr,
			T.Discount,
			cpm.PaymentMethod,
			(T.AmountInDollars + T.Fee + T.StateTax - T.Discount) TotalAmountPaid,
			IIF(CC.IdCountry = @IdCountryUSA, 1, 0) IsDomestic,
			IIF(
				CC.IdCountry = @IdCountryUSA, 
				'Domestic Transmission (DOLLAR TO DOLLAR)',
				CONCAT(
					'International Transmission',
					' (',
					py.PaymentName,
					IIF(CC.IdCurrency = @IdCurrencyUSA, ' - DOLLAR TO DOLLAR', ''),
					')'
				)
			) TypeOfService
			FROM PreTransfer T WITH (NOLOCK)       
			INNER JOIN Agent A WITH (NOLOCK) ON A.IdAgent = T.IdAgent      
			INNER JOIN Users U WITH (NOLOCK) ON U.IdUser = T.EnterByIdUser      
			INNER JOIN Beneficiary B WITH (NOLOCK) ON B.IdBeneficiary = T.IdBeneficiary      
			INNER JOIN Payer P WITH (NOLOCK) ON P.IdPayer = T.IdPayer      
			INNER JOIN PaymentType Py WITH (NOLOCK) ON Py.IdPaymentType = T.IdPaymentType      
			INNER JOIN CountryCurrency CC WITH (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency      
			INNER JOIN Currency CCu WITH (NOLOCK) ON CCu.IdCurrency = CC.IdCurrency      
			INNER JOIN Country CCo WITH (NOLOCK) ON CCo.IdCountry = CC.IdCountry      
			LEFT JOIN Branch Br WITH (NOLOCK) ON Br.IdBranch = T.IdBranch      
			LEFT JOIN City BrC WITH (NOLOCK) ON BrC.IdCity = Br.IdCity      
			LEFT JOIN [State] BrS WITH (NOLOCK) ON BrS.IdState = BrC.IdState      
			LEFT JOIN GatewayBranch GB WITH (NOLOCK) ON GB.IdBranch = T.IdBranch AND GB.IdGateway = T.IdGateway
			LEFT JOIN [dbo].[AccountType] AT WITH (NOLOCK) ON T.[AccountTypeId] = AT.[AccountTypeId]
			JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)  
			WHERE T.IdPreTransfer = @IdTransfer
	END
	ELSE
	BEGIN
		SELECT       
			@CorporationPhone CorporationPhone,      
			@CorporationName CorporationName,    
			@PreTransferEnglishMessage PreTransferEnglishMessage,
			@PreTransferSpanishMessage PreTransferSpanishMessage,  
			A.AgentCode + ' ' + A.AgentName AgentName,      
			A.AgentAddress,      
			A.AgentCity + ' ' + A.AgentState + ' ' + REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AgentLocation,
			A.AgentPhone,      
			T.Folio,       
			U.UserLogin,      
			@LocalDate as DateOfPreTransfer,
			T.IdCustomer,      
			T.CustomerName + ' ' + T.CustomerFirstLastName + ' ' + T.CustomerSecondLastName CustomerFullName,      
			T.CustomerAddress,      
			T.CustomerCity + ' ' + T.CustomerState + ' ' + REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') AS  CustomerLocation,      
			T.CustomerPhoneNumber,  
			T.CustomerCelullarNumber,
			CASE
				WHEN T.CustomerIdCarrier <> 0 THEN 'YES'
				ELSE 'NO'
			END AS CustomerReceiveMessage,    
			T.BeneficiaryName + ' ' + T.BeneficiaryFirstLastName + ' ' + T.BeneficiarySecondLastName BeneficiaryFullName,      
			T.BeneficiaryAddress,      
			CASE
				WHEN T.BeneficiaryCity = '' THEN BrC.CityName + ' ' + BrS.StateName + ' ' + Br.zipcode    
				ELSE B.City + ' ' + B.[State] + ' ' + B.Zipcode     
			END AS BeneficiaryLocation,      
			T.BeneficiaryPhoneNumber,    
			T.BeneficiaryCountry,    
			Py.PaymentName,      
			T.AmountInDollars,      
			T.Fee - T.Discount Fee,      
			T.ExRate,      
			P.PayerName,      
			GB.GatewayBranchCode,      
			CASE
				WHEN CCu.CurrencyCode = 'MXP' THEN 'MXN' 
				WHEN (CC.IdCountry = @IdCountryUSA) THEN 'US'
				ELSE CCu.CurrencyCode 
			END AS CurrencyCode,     
			T.AmountInMN,      
			0.0 OtherFeeMN,
			CCo.CountryName + ' ' + CCu.CurrencyName CountryCurrency,      
			T.DepositAccountNumber,      
			Br.BranchName,  
			CASE 
				WHEN EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) THEN CCo.CountryName
				WHEN ISNULL(BrS.StateName, '') = '' THEN CCo.CountryName
				ELSE CONCAT(BrC.CityName, ' ', BrS.StateName, ', ', CCo.CountryName)
			END AS BranchLocation,  
			ISNULL(CASE a.Agentstate
				WHEN 'OK' THEN 'Oklahoma' 
				WHEN NULL THEN '' 
				ELSE a.Agentstate
			END,'') StateTax,
			ISNULL(t.statetax,dbo.fn_getStateTaxFromTransfer(@IdTransfer)) AS Tax,
			@ComprobanteMessage as ComprobanteMessage,
			@DisclaimerES01 DisclaimerES01,
			@DisclaimerEn01 DisclaimerEn01,
			@DisclaimerES02 DisclaimerES02,
			@DisclaimerEn02 DisclaimerEn02,
			@DisclaimerES03 DisclaimerES03,
			@DisclaimerEn03 DisclaimerEn03,
			CASE
				WHEN T.IdGateway = 4 AND T.IdPaymentType IN (1,4) and T.IdCountryCurrency = @IdCountryCurrencyMexicoPesos and T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars*T.ExRate,2) THEN '*** ' + @DisclaimerEN07 + '.'
				ELSE ''
			END DisclaimerEn07,
			CASE
				WHEN T.IdGateway = 4 AND T.IdPaymentType IN (1,4) AND T.IdCountryCurrency = @IdCountryCurrencyMexicoPesos AND T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars*T.ExRate,2) THEN '*** ' + @DisclaimerEs07 + '.'
				ELSE ''
			END DisclaimerEs07,
			'' AccountTypeName, --AT.[AccountTypeName],
			report.HTML_JUSTIFY(@DisclaimerEn01 + '*** '+ @DisclaimerEn02 + '*** '+ @DisclaimerEn03 + @DisclaimerEN07,
			61, 'Consolas', 7,0,0) AS EngMessPreReceipt,
			report.HTML_JUSTIFY(@DisclaimerES01 + '*** '+ @DisclaimerES02 + '*** '+ @DisclaimerES03 + @DisclaimerES07,
			61, 'Consolas', 7,0,0) AS SpaMessPreReceipt 
			, EmphasizedDisclamer = Convert(BIT,CASE WHEN A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN 1 ELSE 0 END)
			, BeneficiaryMirrorFullName = NULL
			, BeneficiaryMirrorAddress = NULL
			, BeneficiaryMirrorLocation = NULL
			, BeneficiaryMirrorPhoneNumber = NULL
			, BeneficiaryMirrorCountry = NULL
			, @PrintedDate AS PrintedDate
			, @TimeZone AS TimeZoneAbbr,
			T.Discount,
			cpm.PaymentMethod,
			(T.AmountInDollars + T.Fee + T.StateTax - T.Discount) TotalAmountPaid,
			IIF(CC.IdCountry = @IdCountryUSA, 1, 0) IsDomestic,
			IIF(
				CC.IdCountry = @IdCountryUSA, 
				'Domestic Transmission (DOLLAR TO DOLLAR)',
				CONCAT(
					'International Transmission',
					' (',
					py.PaymentName,
					IIF(CC.IdCurrency = @IdCurrencyUSA, ' - DOLLAR TO DOLLAR', ''),
					')'
				)
			) TypeOfService
			FROM PreTransferClosed T WITH (NOLOCK)       
			INNER JOIN Agent A WITH (NOLOCK) ON A.IdAgent = T.IdAgent      
			INNER JOIN Users U WITH (NOLOCK) ON U.IdUser = T.EnterByIdUser      
			INNER JOIN Beneficiary B WITH (NOLOCK) ON B.IdBeneficiary = T.IdBeneficiary      
			INNER JOIN Payer P WITH (NOLOCK) ON P.IdPayer = T.IdPayer      
			INNER JOIN PaymentType Py WITH (NOLOCK) ON Py.IdPaymentType = T.IdPaymentType      
			INNER JOIN CountryCurrency CC WITH (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency      
			INNER JOIN Currency CCu WITH (NOLOCK) ON CCu.IdCurrency = CC.IdCurrency      
			INNER JOIN Country CCo WITH (NOLOCK) ON CCo.IdCountry = CC.IdCountry      
			LEFT JOIN Branch Br WITH (NOLOCK) ON Br.IdBranch = T.IdBranch      
			LEFT JOIN City BrC WITH (NOLOCK) ON BrC.IdCity = Br.IdCity      
			LEFT JOIN [State] BrS WITH (NOLOCK) ON BrS.IdState = BrC.IdState      
			LEFT JOIN GatewayBranch GB WITH (NOLOCK) ON GB.IdBranch = T.IdBranch AND GB.IdGateway = T.IdGateway
			LEFT JOIN [dbo].[AccountType] AT WITH (NOLOCK) ON T.[AccountTypeId] = AT.[AccountTypeId]
			JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)  
			WHERE T.IdPreTransferClosed = @IdTransfer
	END
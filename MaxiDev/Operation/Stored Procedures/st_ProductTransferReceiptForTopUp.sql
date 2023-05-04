CREATE procedure [Operation].[st_ProductTransferReceiptForTopUp] 
(
	@IdProductTransfer bigint
)
as
/********************************************************************
<Author>Dario Almeida</Author>
<app></app>
<Description>Recibo de Billpayment internacional</Description>
--"TransferToSet"
<ChangeLog>
<log Date="2017/05/30" Author="dalmeida"> Creacion </log>
<log Date="2018/06/16" Author="mhinojo"> Recibo igual q envios </log>
<log Date="2019/10/28" Author="bortega">Modificación de Disclamers. :: Ref: M00118-Adecuación de Recibos</log>
<log Date="2022/07/04" Author="saguilar">Se agrega funcion para conversion de hora local por agente </log>
<log Date="2022/07/06" Author="jcsierra">Se realiza Merge entre cambios de recibos y UTC</log>
<log Date="2022/07/18" Author="jcsierra">Se agrega la columna PrintTermsAndConditions para imprimir terminos en caso que el monto sea menor a 15 USD</log>
<log Date="2022/07/27" Author="jcsierra">Se asigna PrintTermsAndConditions = false en todos los casos</log>
<log Date="2022/07/27" Author="jcsierra">Se asinga PrintTermsAndConditions en base a regla de 15 usd y domesticos / internacionales</log>
<log Date="2022/11/04" Author="maprado" name="MP-1311">Cambio de TyC</log>
<log Date="2022/12/30" Author="maprado">Se mapea campo CustomerFullName para Lunex</log>
<log Date="2023/03/28" Author="maprado" name="BM-1247">Cambio de logica de obtencion de TyC Domesticos</log>
<log Date="2023/04/06" Author="maprado" name="BM-1247">Cambio de logica de reglas de TyC para 15 dlls y Domesticos (se remueven ambas reglas)</log>
</ChangeLog>
*********************************************************************/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

declare @IdOtherProduct int

declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');   
  
declare @ReceiptPureMinutesEnglishMessage varchar(max)      
set @ReceiptPureMinutesEnglishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesEnglishMessage');   

declare @ReceiptPureMinutesSpanishMessage varchar(max)      
set @ReceiptPureMinutesSpanishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesSpanishMessage');   

select @IdOtherProduct=IdOtherProduct from operation.ProductTransfer WITH (NOLOCK) where IdProductTransfer=@IdProductTransfer

declare  @AgentState varchar(10)
declare  @IdAgent int
SELECT @IdAgent = t.IdAgent, @AgentState = AgentState FROM [Operation].[ProductTransfer] t WITH (NOLOCK) inner join Agent a WITH (NOLOCK) on a.IdAgent= t.IdAgent where IdProductTransfer=@IdProductTransfer

--get lenguage resource
declare @lenguage1 int
declare @lenguage2 int

select @lenguage1=idlenguage from countrylenguage WITH (NOLOCK) where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryUSA'))
select @lenguage2=idlenguage from countrylenguage WITH (NOLOCK) where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryMexico'))

declare @ReceiptTransferEnglishMessage varchar(max)   
declare @ReceiptTransferSpanishMessage varchar(max)   
--disclaimers

declare @DisclaimerES01 nvarchar(max)
declare @DisclaimerES02 nvarchar(max)
declare @DisclaimerES03 nvarchar(max)
declare @DisclaimerES04 nvarchar(max)
declare @DisclaimerES05 nvarchar(max)
declare @DisclaimerES06 nvarchar(max)
declare @DisclaimerES07 nvarchar(max)

declare @DisclaimerES08 nvarchar(max)

declare @DisclaimerEN01 nvarchar(max)
declare @DisclaimerEN02 nvarchar(max)
declare @DisclaimerEN03 nvarchar(max)
declare @DisclaimerEN04 nvarchar(max)
declare @DisclaimerEN05 nvarchar(max)
declare @DisclaimerEN06 nvarchar(max)
declare @DisclaimerEN07 nvarchar(max)

declare @DisclaimerEN08 nvarchar(max)
declare @EmphasizedDisclamer bit


DECLARE @AffiliationNoticeEnglish AS NVARCHAR(MAX) 
DECLARE @AffiliationNoticeSpanish AS NVARCHAR(MAX) 
declare @DisclaimerFederalEN nvarchar(max)
declare @Disclaimer13EN nvarchar(max)
DECLARE @ComplaintNoticeEnglish AS NVARCHAR(MAX) 
DECLARE @ComplaintNoticeSpanish AS NVARCHAR(MAX) 
declare @DisclaimerFederalES nvarchar(max)
declare @Disclaimer13ES nvarchar(max) = ''



SELECT 
	@AffiliationNoticeEnglish = ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),''), 
	@ComplaintNoticeEnglish = ComplaintNoticeEnglish, 
	@AffiliationNoticeSpanish = ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),''), 
	@ComplaintNoticeSpanish = ComplaintNoticeSpanish 
FROM Agent A WITH (NOLOCK) INNER JOIN  [State] S WITH (NOLOCK) ON S.StateCode = A.AgentState INNER JOIN StateNote SN WITH (NOLOCK) ON SN.IdState = S.IdState WHERE IdAgent = @IdAgent

select 
	@ReceiptTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferMessage'),   
    @ReceiptTransferSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ReceiptTransferMessage'),
    @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill01'), --Ref: M00118-Adecuación de Recibos
    @DisclaimerEN02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill02'),
    @DisclaimerEN03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill03'),
    @DisclaimerEN04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill04'),
    @DisclaimerEN05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill05'),
    @DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill01'),
    @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill02'),
    @DisclaimerES03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill03'),
    @DisclaimerES04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill04'),
    @DisclaimerES05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill05'), --Ref: M00118-Adecuación de Recibos
	@DisclaimerFederalEN=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerFederalEN'),
	@DisclaimerFederalES= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalES'),
	@EmphasizedDisclamer = 0

IF (@AgentState = 'CA')
BEGIN
	select @DisclaimerEN04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill04CA') --Ref: M00118-Adecuación de Recibos
	select @DisclaimerES04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill04CA') --Ref: M00118-Adecuación de Recibos
END
ELSE
BEGIN
	SET @DisclaimerES05 = ''
	SET @DisclaimerEN05 = ''
END

SELECT @DisclaimerFederalEN=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerFederalEN')
SELECT @DisclaimerFederalES= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalES') 

declare @DisclaimerES01Pre nvarchar(max)
declare @DisclaimerES02Pre nvarchar(max)
declare @DisclaimerES03Pre nvarchar(max)
declare @DisclaimerES07Pre nvarchar(max)
declare @DisclaimerEN01Pre nvarchar(max)
declare @DisclaimerEN02Pre nvarchar(max)
declare @DisclaimerEN03Pre nvarchar(max)
declare @DisclaimerEN07Pre nvarchar(max)


select 
	@DisclaimerEN01Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1'),
    @DisclaimerEN02Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer2'),
    @DisclaimerEN03Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer3'),
	@DisclaimerEN07Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer7'),

    @DisclaimerES01Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer1'),
    @DisclaimerES02Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer2'),
    @DisclaimerES03Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer3'),
	@DisclaimerES07Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer7')



DECLARE @TimeZoneAbbr				VARCHAR(200),
		@PrintDateTime				DATETIME,
		@PaymentMethod				VARCHAR(200),
		@DisclaimerEn				VARCHAR(MAX),
		@DisclaimerCAEn				VARCHAR(MAX),
		@DisclaimerES				VARCHAR(MAX),
		@DisclaimerCAEs				VARCHAR(MAX),
		@TotalOperationAmount		MONEY,
		@IdCurrencyUSA				INT,
		@CurrencyCodeUSA			VARCHAR(20),
		@DateAvailableExtraDays		INT,
		@PrintTermsAndConditions	BIT

SET @DateAvailableExtraDays = 0

SET @IdCurrencyUSA = dbo.GetGlobalAttributeByName('IdCurrencyUSA')
SELECT
	@CurrencyCodeUSA = c.CurrencyCode
FROM Currency c WITH(NOLOCK)
WHERE c.IdCurrency = @IdCurrencyUSA


--- Conversion Hora Local 

Declare @receiptType int = 1

	   Select DateOfTransferLocal,
			  PrintedDate,
			  TimeZone

		into #LocalTime                       
			 from [dbo].[FnConvertLocalTimeZoneOP] (@IdProductTransfer,@receiptType) -- Se invoca Funcion Timezone
		
	Declare @LocalDate datetime,
			@PrintedDate datetime,
			@TimeZone nvarchar(3)

	 select @LocalDate=DateOfTransferLocal,
	        @TimeZone=TimeZone,
			@PrintedDate=PrintedDate
	 from #LocalTime
		
		Drop table #LocalTime
				

--- Termina Conversion

SELECT 
	@TimeZoneAbbr = @TimeZone,
	@PrintDateTime = @PrintedDate,
	@PaymentMethod = 'Cash',
	@DisclaimerEn = CONCAT(
		@DisclaimerEn01, ' ',
		@DisclaimerEn02, ' ',
		@DisclaimerEn03, ' ',
		@ComplaintNoticeEnglish, ' ',
		'or Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov. ',
		@DisclaimerEn04
	),
	@DisclaimerCAEn = @DisclaimerEn05,
	@DisclaimerES = CONCAT(
		@DisclaimerES01, ' ',
		@DisclaimerES02, ' ',
		@DisclaimerES03, ' ',
		@ComplaintNoticeSpanish, ' ',
		'o Consumer Financial Protecction Bureau al  855-441-2372, 855-729-2372 (TTY / TDD) www.consumerfinance.gov. ',
		@DisclaimerES04
	),
	@DisclaimerCAEs = @DisclaimerES05,
	@TotalOperationAmount = t.Amount + t.Fee,
	--@PrintTermsAndConditions = IIF(t.Amount < 15, 0, 1)
	@PrintTermsAndConditions = 1
FROM [Operation].[ProductTransfer] t WITH(NOLOCK)
WHERE
	t.IdProductTransfer=@IdProductTransfer

--

/*
9	Lunex Top Up
10	Lunex Long Distance
11	Lunex Gift Card
13	Lunex Call USA UNLIMITED
16	MEGA Unlimited Mexico $5
*/
if @IdOtherProduct in (9,10,11,12,13,16) 
begin  
  
    Select       
      @CorporationPhone CorporationPhone,      
      @CorporationName CorporationName,     
      @ReceiptPureMinutesEnglishMessage ReceiptEnglishMessage,
      @ReceiptPureMinutesSpanishMessage ReceiptSpanishMessage,  
      ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
      A.AgentAddress,      
      ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ 
	    REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS  AgentLocation,      
      A.AgentPhone,
      t.IdProductTransfer,
      t.TransactionProviderID IdTransaction,
      @LocalDate DateOfTransaction,   
      IIF(ISNULL(piv.TopupPhone, '') <> '', piv.TopupPhone, piv.Phone) Phonenumber,
      t.Amount Amount,  
      t.TransactionProviderID Reference,
      ISNULL(c.CountryName, 'Estados Unidos') CountryName,
      piv.SKUName CarrierName,        
      'USD' LocalCurrency,
      null pinBased,
      null pinValidity,
      null pinCode,
      null pinIvr,
      null pinSerial,
      piv.pin pinValue,
      null pinOption1,
      null pinOption2,
      null pinOption3,
      piv.[key] [Key],  
      piv.ReceivedValue LocalInfoValue,
      piv.ReceivedValue LocalAmountReceived    
        , A.AgentFax	
	    , A.AgentName AS AgentNameTicket
	    , A.AgentCode
	    , A.AgentZipcode
	    , A.AgentState
	    , A.AgentCity
        ,t.EnterByIdUser
        ,u.UserLogin UserName
        ,t.EnterByIdUserCancel
        ,t.TransactionProviderCancelDate DateOfCancelTransaction
        ,isnull(u2.UserLogin,'') UserNameCancel
		,ISNULL(t.Fee, 0) AS Fee,
		@DisclaimerES01 DisclaimerES01,
          @DisclaimerEn01 DisclaimerEn01,
          @DisclaimerES02 DisclaimerES02,
          @DisclaimerEn02 DisclaimerEn02,
          @DisclaimerES03 DisclaimerES03,
          @DisclaimerEn03 DisclaimerEn03,
		  @DisclaimerES04 DisclaimerES04,
          @DisclaimerEn04 DisclaimerEn04,
          @DisclaimerES05 DisclaimerES05,
          @DisclaimerEn05 DisclaimerEn05,
		  --@DisclaimerES06 DisclaimerES06,
          --@DisclaimerEn06 DisclaimerEn06,
		  --@DisclaimerES08 DisclaimerEs08,
          --@DisclaimerEN08 DisclaimerEn08,
		  '*** ' + @DisclaimerEN07 + '.' DisclaimerEn07,
		  '*** ' + @DisclaimerEs07 + '.' DisclaimerEs07,
		  @EmphasizedDisclamer AS EmphasizedDisclamer,
		  piv.SenderName AS CustomerFullName,
		  @AffiliationNoticeEnglish AffiliationNoticeEnglish,
		  @AffiliationNoticeSpanish AffiliationNoticeSpanish,
		  @DisclaimerFederalEN DisclaimerFederalEN, 
			@Disclaimer13EN Disclaimer13EN,
		@ComplaintNoticeEnglish ComplaintNoticeEnglish,
		@ComplaintNoticeSpanish ComplaintNoticeSpanish,
		@DisclaimerFederalES DisclaimerFederalES,
		@Disclaimer13ES Disclaimer13ES,
		@ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		@ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,
		'I attest to have received $'+ CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' from the customer/reconozco haber recibido $'
		  + CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' del cliente' AttestMessage
		,0 Tax
		,Case A.AgentState When 'OK' Then 'Oklahoma' When NULL Then case when a.agentstate='OK' Then 'Oklahoma' when a.agentstate!='OK' Then a.agentstate else ''END Else  AgentState End StateTax,
				  @DisclaimerES01Pre DisclaimerES01Pre,
		@DisclaimerES02Pre DisclaimerES02Pre,
		@DisclaimerES03Pre DisclaimerES03Pre,
		@DisclaimerES07Pre DisclaimerES07Pre,
		@DisclaimerEN01Pre DisclaimerEN01Pre,
		@DisclaimerEN02Pre DisclaimerEN02Pre,
		@DisclaimerEN03Pre DisclaimerEN03Pre,
		@DisclaimerEN07Pre DisclaimerEN07Pre,
		ISNULL(piv.AmountInMN, piv.Amount)					AmountInMN,
		ISNULL(piv.ExRate, 1)								ExRate,
		ISNULL(piv.CountryCurrency, 'USD')		CountryCurrency,

		@TimeZoneAbbr										TimeZoneAbbr,
		@PrintDateTime										PrintDateTime,
		@PaymentMethod										PaymentMethod,
		IIF(c.CountryISOCode IS NULL OR ISNULL(c.CountryISOCode, '') = 'USA',
			[dbo].[fn_GetTyC] (1,1,1),
			@DisclaimerEn
		)													DisclaimerEn,
		IIF(c.CountryISOCode IS NULL OR ISNULL(c.CountryISOCode, '') = 'USA',
			IIF( a.AgentState = 'CA',
				[dbo].[fn_GetTyC] (1,0,1),
				''),
			@DisclaimerCAEn
		)													DisclaimerCAEn,
		IIF(c.CountryISOCode IS NULL OR ISNULL(c.CountryISOCode, '') = 'USA',
			[dbo].[fn_GetTyC] (1,1,2),
			@DisclaimerES
		)													DisclaimerES,
		IIF(c.CountryISOCode IS NULL OR ISNULL(c.CountryISOCode, '') = 'USA',
			IIF( a.AgentState = 'CA',
				[dbo].[fn_GetTyC] (1,0,2),
				''),
			@DisclaimerCAEs
		)													DisclaimerCAEs,
		@TotalOperationAmount								TotalOperationAmount,

		piv.SenderAddress									CustomerAddress,
		piv.Phone											CustomerCelullarNumber,
		IIF(
			c.CountryISOCode IS NULL OR ISNULL(c.CountryISOCode, '') = 'USA',
			'Domestic Top-Up (Dollar to Dollar)',
			'International Top-Up'
		)													TypeOfService,
		CONVERT(DATE, DATEADD(DAY, @DateAvailableExtraDays, @LocalDate))	DateAvailable,
		ISNULL(piv.AmountInMN, piv.Amount)					TotalOperationAmountInMN,
		0													OtherFeeMN,
		IIF(c.CountryISOCode IS NULL OR ISNULL(c.CountryISOCode, '') = 'USA', 1, 0)		IsDomestic,
		piv.AccessNumber,
		--IIF(c.CountryISOCode IS NULL OR ISNULL(c.CountryISOCode, '') = 'USA', 0, @PrintTermsAndConditions)	PrintTermsAndConditions
		@PrintTermsAndConditions PrintTermsAndConditions
    from [Operation].[ProductTransfer] t WITH (NOLOCK)
	    inner join Agent a WITH (NOLOCK) on a.IdAgent= t.IdAgent   
        join users u WITH (NOLOCK) on t.EnterByIdUser=u.iduser        
        left join users u2 WITH (NOLOCK) on t.EnterByIdUserCancel=u2.iduser     
        join lunex.TransferLN piv WITH (NOLOCK) on piv.IdProductTransfer=t.IdProductTransfer

		LEFT JOIN lunex.Product p WITH (NOLOCK) ON p.SKU = piv.SKU
		LEFT JOIN Operation.Country c WITH (NOLOCK) ON p.IdCountry = c.IdCountry
    where t.IdProductTransfer=@IdProductTransfer
end

/* 6	Top Up */
if @IdOtherProduct=6 
begin  
  
    Select       
      @CorporationPhone CorporationPhone,      
      @CorporationName CorporationName,     
      @ReceiptPureMinutesEnglishMessage ReceiptEnglishMessage,
      @ReceiptPureMinutesSpanishMessage ReceiptSpanishMessage,  
      ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
      A.AgentAddress,      
      ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ 
	    REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS  AgentLocation,      
      A.AgentPhone,
      t.IdProductTransfer,
      t.TransactionProviderID IdTransaction,
      @LocalDate DateOfTransaction,   
      piv.topupnumber Phonenumber,
      t.Amount Amount,  
      t.TransactionProviderID Reference,
      co.Countryname CountryName,
      ca.CarrierName CarrierName,        
      null LocalCurrency,
      null pinBased,
      null pinValidity,
      null pinCode,
      null pinIvr,
      null pinSerial,
      null pinValue,
      null pinOption1,
      null pinOption2,
      null pinOption3,
      null [Key],  
      null LocalInfoValue,
      piv.ReceiverAmount LocalAmountReceived     
        , A.AgentFax	
	    , A.AgentName AS AgentNameTicket
	    , A.AgentCode
	    , A.AgentZipcode
	    , A.AgentState
	    , A.AgentCity
        ,t.EnterByIdUser
        ,u.UserLogin UserName
        ,t.EnterByIdUserCancel
        ,t.TransactionProviderCancelDate DateOfCancelTransaction
        ,isnull(u2.UserLogin,'') UserNameCancel
		, 0 AS Fee,
		@DisclaimerES01 DisclaimerES01,
          @DisclaimerEn01 DisclaimerEn01,
          @DisclaimerES02 DisclaimerES02,
          @DisclaimerEn02 DisclaimerEn02,
          @DisclaimerES03 DisclaimerES03,
          @DisclaimerEn03 DisclaimerEn03,
		  @DisclaimerES04 DisclaimerES04,
          @DisclaimerEn04 DisclaimerEn04,
          @DisclaimerES05 DisclaimerES05,
          @DisclaimerEn05 DisclaimerEn05,
		  --@DisclaimerES06 DisclaimerES06,
          --@DisclaimerEn06 DisclaimerEn06,
		  --@DisclaimerES08 DisclaimerEs08,
          --@DisclaimerEN08 DisclaimerEn08,
		  '*** ' + @DisclaimerEN07 + '.' DisclaimerEn07,
		  '*** ' + @DisclaimerEs07 + '.' DisclaimerEs07,
		  @EmphasizedDisclamer as EmphasizedDisclamer,
		  '' CustomerFullName,
		  @AffiliationNoticeEnglish AffiliationNoticeEnglish,
		  @AffiliationNoticeSpanish AffiliationNoticeSpanish,
		  @DisclaimerFederalEN DisclaimerFederalEN, 
			@Disclaimer13EN Disclaimer13EN,
		@ComplaintNoticeEnglish ComplaintNoticeEnglish,
		@ComplaintNoticeSpanish ComplaintNoticeSpanish,
		@DisclaimerFederalES DisclaimerFederalES,
		@Disclaimer13ES Disclaimer13ES,
		@ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		@ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,
		'I attest to have received $'+ CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' from the customer/reconozco haber recibido $'
		  + CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' del cliente' AttestMessage
		  ,0 Tax
		  ,Case A.AgentState When 'OK' Then 'Oklahoma' When NULL Then case when a.agentstate='OK' Then 'Oklahoma' when a.agentstate!='OK' Then a.agentstate else ''END Else  AgentState End StateTax,
				  @DisclaimerES01Pre DisclaimerES01Pre,
		@DisclaimerES02Pre DisclaimerES02Pre,
		@DisclaimerES03Pre DisclaimerES03Pre,
		@DisclaimerES07Pre DisclaimerES07Pre,
		@DisclaimerEN01Pre DisclaimerEN01Pre,
		@DisclaimerEN02Pre DisclaimerEN02Pre,
		@DisclaimerEN03Pre DisclaimerEN03Pre,
		@DisclaimerEN07Pre DisclaimerEN07Pre,
		CAST(ISNULL(piv.RechargeAmount,0) AS MONEY) AmountInMN,
		CAST(ISNULL(piv.RechargeAmount,0) AS MONEY) / t.Amount ExRate,
		piv.RechargeCurrency CountryCurrency,


		@TimeZoneAbbr										TimeZoneAbbr,
		@PrintDateTime										PrintDateTime,
		@PaymentMethod										PaymentMethod,
		@DisclaimerEn										DisclaimerEn,
		@DisclaimerCAEn										DisclaimerCAEn,
		@DisclaimerES										DisclaimerES,
		@DisclaimerCAEs										DisclaimerCAEs,
		@TotalOperationAmount								TotalOperationAmount,

		''													CustomerAddress,
		piv.BuyerPhonenumber								CustomerCelullarNumber,
		'International Top-Up'								TypeOfService,
		CONVERT(DATE, DATEADD(DAY, @DateAvailableExtraDays, @LocalDate))	DateAvailable,
		CAST(ISNULL(piv.RechargeAmount,0) AS MONEY)			TotalOperationAmountInMN,
		0													OtherFeeMN,
		1													IsDomestic,
		NULL												AccessNumber,
		0													PrintTermsAndConditions
    from [Operation].[ProductTransfer] t WITH (NOLOCK)
	    inner join Agent a WITH (NOLOCK) on a.IdAgent= t.IdAgent   
        join users u WITH (NOLOCK) on t.EnterByIdUser=u.iduser        
        left join users u2 WITH (NOLOCK) on t.EnterByIdUserCancel=u2.iduser     
        join pureminutestopuptransaction piv WITH (NOLOCK) on piv.IdProductTransfer=t.IdProductTransfer
        left join CarrierPureMinutesTopUp ca WITH (NOLOCK) on piv.CarrierID=ca.IdCarrierPureMinutesTopUp
        left join CountryPureMinutesTopUp co WITH (NOLOCK) on piv.CountryID=co.IdCountryPureMinutesTopUp
    where t.IdProductTransfer=@IdProductTransfer
end

/* 7	Top UP */
if @IdOtherProduct=7
begin  
  
    Select       
      @CorporationPhone CorporationPhone,      
      @CorporationName CorporationName,     
      @ReceiptPureMinutesEnglishMessage ReceiptEnglishMessage,
      @ReceiptPureMinutesSpanishMessage ReceiptSpanishMessage,  
       ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
      A.AgentAddress,      
      ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ 
	    REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS  AgentLocation,      
      A.AgentPhone,
      t.IdProductTransfer,
      t.TransactionProviderID IdTransaction,
      @LocalDate DateOfTransaction,   
      piv.Destination_Msisdn Phonenumber,
      t.Amount Amount,  
      t.TransactionProviderID Reference,
      piv.Country CountryName,
      operator CarrierName,        
      LocalInfoCurrency LocalCurrency,
      pinBased,
      pinValidity,
      pinCode,
      pinIvr,
      pinSerial,
      pinValue,
      pinOption1,
      pinOption2,
      pinOption3,
      [Key],  
      LocalInfoValue,
      LocalInfoAmount LocalAmountReceived   
        , A.AgentFax	
	    , A.AgentName AS AgentNameTicket
	    , A.AgentCode
	    , A.AgentZipcode
	    , A.AgentState
	    , A.AgentCity
        ,t.EnterByIdUser
        ,u.UserLogin UserName
        ,t.EnterByIdUserCancel
        ,t.TransactionProviderCancelDate DateOfCancelTransaction
        ,isnull(u2.UserLogin,'') UserNameCancel
		, 0 AS Fee,
		@DisclaimerES01 DisclaimerES01,
          @DisclaimerEn01 DisclaimerEn01,
          @DisclaimerES02 DisclaimerES02,
          @DisclaimerEn02 DisclaimerEn02,
          @DisclaimerES03 DisclaimerES03,
          @DisclaimerEn03 DisclaimerEn03,
		  @DisclaimerES04 DisclaimerES04,
          @DisclaimerEn04 DisclaimerEn04,
          @DisclaimerES05 DisclaimerES05,
          @DisclaimerEn05 DisclaimerEn05,
		  --@DisclaimerES06 DisclaimerES06,
          --@DisclaimerEn06 DisclaimerEn06,
		  --@DisclaimerES08 DisclaimerEs08,
          --@DisclaimerEN08 DisclaimerEn08,
		  '*** ' + @DisclaimerEN07 + '.' DisclaimerEn07,
		  '*** ' + @DisclaimerEs07 + '.' DisclaimerEs07,
		  @EmphasizedDisclamer as EmphasizedDisclamer,
		  LTRIM(RTRIM(ISNULL(C.Name,'')+' '+ ISNULL(C.FirstLastName,'')+' '+ISNULL(C.SecondLastName,''))) CustomerFullName,
		  @AffiliationNoticeEnglish AffiliationNoticeEnglish,
		  @AffiliationNoticeSpanish AffiliationNoticeSpanish,
		  @DisclaimerFederalEN DisclaimerFederalEN, 
			@Disclaimer13EN Disclaimer13EN,
		@ComplaintNoticeEnglish ComplaintNoticeEnglish,
		@ComplaintNoticeSpanish ComplaintNoticeSpanish,
		@DisclaimerFederalES DisclaimerFederalES,
		@Disclaimer13ES Disclaimer13ES,
		@ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		@ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,
		'I attest to have received $'+ CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' from the customer/reconozco haber recibido $'
		  + CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' del cliente' AttestMessage
		  ,0 Tax
		  ,Case A.AgentState When 'OK' Then 'Oklahoma' When NULL Then case when a.agentstate='OK' Then 'Oklahoma' when a.agentstate!='OK' Then a.agentstate else ''END Else  AgentState End StateTax,
		 		  @DisclaimerES01Pre DisclaimerES01Pre,
		@DisclaimerES02Pre DisclaimerES02Pre,
		@DisclaimerES03Pre DisclaimerES03Pre,
		@DisclaimerES07Pre DisclaimerES07Pre,
		@DisclaimerEN01Pre DisclaimerEN01Pre,
		@DisclaimerEN02Pre DisclaimerEN02Pre,
		@DisclaimerEN03Pre DisclaimerEN03Pre,
		@DisclaimerEN07Pre DisclaimerEN07Pre,
		piv.LocalInfoAmount AmountInMN,
		piv.LocalInfoAmount / t.Amount ExRate,
		LocalInfoCurrency CountryCurrency,

		@TimeZoneAbbr										TimeZoneAbbr,
		@PrintDateTime										PrintDateTime,
		@PaymentMethod										PaymentMethod,
		IIF(ISNULL(piv.Country, '') = 'UNITED STATES',
			[dbo].[fn_GetTyC] (1,1,1),
			@DisclaimerEn
		)													DisclaimerEn,
		IIF(ISNULL(piv.Country, '') = 'UNITED STATES',
			IIF( a.AgentState = 'CA',
				[dbo].[fn_GetTyC] (1,0,1),
				''),
			@DisclaimerCAEn
		)													DisclaimerCAEn,
		IIF(ISNULL(piv.Country, '') = 'UNITED STATES',
			[dbo].[fn_GetTyC] (1,1,2),
			@DisclaimerES
		)													DisclaimerES,
		IIF(ISNULL(piv.Country, '') = 'UNITED STATES',
			IIF( a.AgentState = 'CA',
				[dbo].[fn_GetTyC] (1,0,2),
				''),
			@DisclaimerCAEs
		)													DisclaimerCAEs,
		@TotalOperationAmount								TotalOperationAmount,

		CONCAT(
			c.Address, ', ', 
			c.City, ' ', 
			c.State, ' ', 
			REPLACE(STR(isnull(c.Zipcode,0), 5), SPACE(1), '0')
		) CustomerAddress,
		c.CelullarNumber									CustomerCelullarNumber,
		IIF(
			ISNULL(piv.Country, '') = 'UNITED STATES',
			'Domestic Top-Up (Dollar to Dollar)',
			'International Top-Up'
		)													TypeOfService,
		CONVERT(DATE, DATEADD(DAY, @DateAvailableExtraDays, @LocalDate))	DateAvailable,
		piv.LocalInfoAmount									TotalOperationAmountInMN,
		0													OtherFeeMN,
		IIF(ISNULL(piv.Country, '') = 'UNITED STATES', 1, 0)		IsDomestic,
		NULL												AccessNumber,
		--IIF(ISNULL(piv.Country, '') = 'UNITED STATES', 0, @PrintTermsAndConditions)	PrintTermsAndConditions
		@PrintTermsAndConditions PrintTermsAndConditions
    from [Operation].[ProductTransfer] t WITH (NOLOCK)
	    inner join Agent a WITH (NOLOCK) on a.IdAgent= t.IdAgent   
        join users u WITH (NOLOCK) on t.EnterByIdUser=u.iduser        
        left join users u2 WITH (NOLOCK) on t.EnterByIdUserCancel=u2.iduser     
        join TransFerTo.TransferTTo piv WITH (NOLOCK) on piv.IdProductTransfer=t.IdProductTransfer
		LEFT JOIN Customer C WITH (NOLOCK) ON C.IdCustomer = piv.idCustomer
    where t.IdProductTransfer=@IdProductTransfer
end

/* 17	Regalii Top Up */
IF @IdOtherProduct=17 -- Regalii TopUp
BEGIN
  
	SELECT
		@CorporationPhone [CorporationPhone],
		@CorporationName [CorporationName],
		@ReceiptPureMinutesEnglishMessage [ReceiptEnglishMessage],
		@ReceiptPureMinutesSpanishMessage [ReceiptSpanishMessage],
		ISNULL(A.[AgentCode],'')+' '+ ISNULL(A.[AgentName],'') [AgentName],
		A.[AgentAddress],
		ISNULL(A.[AgentCity],'')+ ' '+ ISNULL(A.[AgentState],'') + ' '+ REPLACE(STR(isnull(A.[AgentZipcode],0), 5), SPACE(1), '0') AS [AgentLocation],
		A.[AgentPhone],
		T.[IdProductTransfer],
		T.[TransactionProviderID] [IdTransaction],
		@LocalDate [DateOfTransaction],
		PIV.[Account_Number] [Phonenumber],
		T.[Amount] [Amount],
		T.[TransactionProviderID] [Reference],
		PIV.[Country] [CountryName],
		PIV.[Name] [CarrierName],
		PIV.[LocalCurrency] [LocalCurrency],
		NULL [pinBased],
		NULL [pinValidity],
		NULL [pinCode],
		NULL [pinIvr],
		NULL [pinSerial],
		NULL [pinValue],
		NULL [pinOption1],
		NULL [pinOption2],
		NULL [pinOption3],
		NULL [Key],
		PIV.[AmountInMN] [LocalInfoValue],
		PIV.[AmountInMN]+PIV.TopUpBonusAmountReceived [LocalAmountReceived]
		, A.[AgentFax]
		, A.[AgentName] [AgentNameTicket]
		, A.[AgentCode]
		, A.[AgentZipcode]
		, A.[AgentState]
		, A.[AgentCity]
		,T.[EnterByIdUser]
		,U.[UserLogin] [UserName]
		,T.[EnterByIdUserCancel]
		,T.[TransactionProviderCancelDate] [DateOfCancelTransaction]
		,ISNULL(U2.[UserLogin],'') [UserNameCancel]
		, 0 AS Fee,
		@DisclaimerES01 DisclaimerES01,
          @DisclaimerEn01 DisclaimerEn01,
          @DisclaimerES02 DisclaimerES02,
          @DisclaimerEn02 DisclaimerEn02,
          @DisclaimerES03 DisclaimerES03,
          @DisclaimerEn03 DisclaimerEn03,
		  @DisclaimerES04 DisclaimerES04,
          @DisclaimerEn04 DisclaimerEn04,
          @DisclaimerES05 DisclaimerES05,
          @DisclaimerEn05 DisclaimerEn05,
		 -- @DisclaimerES06 DisclaimerES06,
         -- @DisclaimerEn06 DisclaimerEn06,
		  --@DisclaimerES08 DisclaimerEs08,
          --@DisclaimerEN08 DisclaimerEn08,
		  '*** ' + @DisclaimerEN07 + '.' DisclaimerEn07,
		  '*** ' + @DisclaimerEs07 + '.' DisclaimerEs07,
		  @EmphasizedDisclamer as EmphasizedDisclamer,
		  LTRIM(RTRIM(ISNULL(C.Name,'')+' '+ ISNULL(C.FirstLastName,'')+' '+ISNULL(C.SecondLastName,''))) CustomerFullName,
		  @AffiliationNoticeEnglish AffiliationNoticeEnglish,
		  @AffiliationNoticeSpanish AffiliationNoticeSpanish,
		  @DisclaimerFederalEN DisclaimerFederalEN, 
			@Disclaimer13EN Disclaimer13EN,
		@ComplaintNoticeEnglish ComplaintNoticeEnglish,
		@ComplaintNoticeSpanish ComplaintNoticeSpanish,
		@DisclaimerFederalES DisclaimerFederalES,
		@Disclaimer13ES Disclaimer13ES,
		@ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		@ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,
		'I attest to have received $'+ CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' from the customer/reconozco haber recibido $'
		  + CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' del cliente' AttestMessage
		  ,0 Tax
		  ,Case A.AgentState When 'OK' Then 'Oklahoma' When NULL Then case when a.agentstate='OK' Then 'Oklahoma' when a.agentstate!='OK' Then a.agentstate else ''END Else  AgentState End StateTax,
		  @DisclaimerES01Pre DisclaimerES01Pre,
		@DisclaimerES02Pre DisclaimerES02Pre,
		@DisclaimerES03Pre DisclaimerES03Pre,
		@DisclaimerES07Pre DisclaimerES07Pre,
		@DisclaimerEN01Pre DisclaimerEN01Pre,
		@DisclaimerEN02Pre DisclaimerEN02Pre,
		@DisclaimerEN03Pre DisclaimerEN03Pre,
		@DisclaimerEN07Pre DisclaimerEN07Pre,
		PIV.[AmountInMN]+PIV.TopUpBonusAmountReceived AmountInMN,
		piv.ExRate ExRate,
		piv.[LocalCurrency] CountryCurrency,

		@TimeZoneAbbr										TimeZoneAbbr,
		@PrintDateTime										PrintDateTime,
		@PaymentMethod										PaymentMethod,
		IIF(ISNULL(b.Country, '') = 'US',
			[dbo].[fn_GetTyC] (1,1,1),
			@DisclaimerEn
		)													DisclaimerEn,
		IIF(ISNULL(b.Country, '') = 'US',
			IIF( a.AgentState = 'CA',
				[dbo].[fn_GetTyC] (1,0,1),
				''),
			@DisclaimerCAEn
		)													DisclaimerCAEn,
		IIF(ISNULL(b.Country, '') = 'US',
			[dbo].[fn_GetTyC] (1,1,2),
			@DisclaimerES
		)													DisclaimerES,
		IIF(ISNULL(b.Country, '') = 'US',
			IIF( a.AgentState = 'CA',
				[dbo].[fn_GetTyC] (1,0,2),
				''),
			@DisclaimerCAEs
		)													DisclaimerCAEs,
		@TotalOperationAmount								TotalOperationAmount,

		CONCAT(
			c.Address, ', ', 
			c.City, ' ', 
			c.State, ' ', 
			REPLACE(STR(isnull(c.Zipcode,0), 5), SPACE(1), '0')
		) CustomerAddress, 
		c.CelullarNumber									CustomerCelullarNumber,
		IIF(
			ISNULL(b.Country, '') = 'US',
			'Domestic Top-Up (Dollar to Dollar)',
			'International Top-Up'
		)													TypeOfService,
		CONVERT(DATE, DATEADD(DAY, @DateAvailableExtraDays, @LocalDate))	DateAvailable,
		piv.AmountInMN										TotalOperationAmountInMN,
		0													OtherFeeMN,
		IIF(ISNULL(b.Country, '') = 'US', 1, 0)		IsDomestic,
		NULL												AccessNumber,
		--IIF(ISNULL(b.Country, '') = 'US', 0, @PrintTermsAndConditions)	PrintTermsAndConditions
		@PrintTermsAndConditions PrintTermsAndConditions
	FROM [Operation].[ProductTransfer] T WITH (NOLOCK)
	INNER JOIN [dbo].[Agent] A WITH (NOLOCK) ON A.[IdAgent]= T.[IdAgent]
    JOIN [dbo].[Users] U WITH (NOLOCK) ON T.[EnterByIdUser]=U.[Iduser]
    LEFT JOIN [dbo].[Users] U2 WITH (NOLOCK) ON T.[EnterByIdUserCancel]=U2.[Iduser]
    JOIN [Regalii].[TransferR] PIV WITH (NOLOCK) ON PIV.[IdProductTransfer]=T.[IdProductTransfer]
	LEFT JOIN Customer C WITH (NOLOCK) ON C.IdCustomer = piv.idCustomer

	LEFT JOIN Regalii.Billers b WITH (NOLOCK) ON b.IdBiller = piv.IdBiller
    WHERE T.[IdProductTransfer]=@IdProductTransfer

END



CREATE procedure [Regalii].[st_GetTransactionReceiptRegalii](@IdProductTransfer bigint)
as
/********************************************************************
<Author>UNKNOWN</Author>
<app></app>
<Description>Recibo de Billpayment internacional</Description>

<ChangeLog>
<log Date="16/06/2018" Author="mhinojo"> Recibo igual q envios </log>
<log Date="30/09/2019" Author="bortega">Modificación de Disclamers. :: Ref: M00077-Modif. de Recibos</log>
<log Date="10/12/2020" Author="jsierra">Se agregan campos CountryName, OriginalCurrency, IsInternational</log>
<log Date="2022/06/22" Author="jcsierra">Se agregan columnas TimeZoneAbbr, TypeOfService, PaymentMethod, OtherFeeMN, CustomerAddress, CustomerCelullarNumber, DisclaimerEn, DisclaimerCAEn, DisclaimerES, DisclaimerCAEs</log>
<log Date="2022/07/04" Author="saguilar">Se agrega funcion para conversion de hora local por agente </log>
<log Date="2022/07/6"  Author="jcsierra">Se realiza Merge entre cambios de recibos y UTC</log>
<log Date="04/11/2022" Author="maprado" name="MP-1311">Cambio de TyC</log>
</ChangeLog>
*********************************************************************/
BEGIN

	DECLARE @AffiliationNoticeEnglish AS NVARCHAR(MAX) 
	DECLARE @AffiliationNoticeSpanish AS NVARCHAR(MAX) 
	declare @DisclaimerFederalEN nvarchar(max)
	declare @Disclaimer13EN nvarchar(max)
	DECLARE @ComplaintNoticeEnglish AS NVARCHAR(MAX) 
	DECLARE @ComplaintNoticeSpanish AS NVARCHAR(MAX) 
	declare @DisclaimerFederalES nvarchar(max)
	declare @Disclaimer13ES nvarchar(max) 

	declare @ReceiptBillPaymentSpanishMessage varchar(max) = (select Value from GlobalAttributes WITH (NOLOCK) where Name='ReceiptBillPaymentSpanishMessage')
	declare @ReceiptBillPaymentEnglishMessage varchar(max) = (select Value from GlobalAttributes WITH (NOLOCK) where Name='ReceiptBillPaymentEnglishMessage')
	declare @CancelReceiptBillPaymentSpanishMessage varchar(max) = (select Value from GlobalAttributes WITH (NOLOCK) where Name='ReceiptBillPaymentCancelSpanishMessage')
	declare @CancelReceiptBillPaymentEnglishMessage varchar(max) = (select Value from GlobalAttributes WITH (NOLOCK) where Name='ReceiptBillPaymentCancelEnglishMessage')
	declare @CorporationPhone varchar(50) = dbo.GetGlobalAttributeByName('CorporationPhone');      

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

	declare @ReceiptTransferEnglishMessage varchar(max)   
	declare @ReceiptTransferSpanishMessage varchar(max)  

	select 
	@DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](1,'Disclaimer1'),
    @DisclaimerEN02=[dbo].[GetMessageFromMultiLenguajeResorces](1,'Disclaimer2'),
    @DisclaimerEN03=[dbo].[GetMessageFromMultiLenguajeResorces](1,'Disclaimer3'),
	@DisclaimerEN07=[dbo].[GetMessageFromMultiLenguajeResorces](1,'Disclaimer7'),
	@DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](2,'Disclaimer1'),
    @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](2,'Disclaimer2'),
    @DisclaimerES03=[dbo].[GetMessageFromMultiLenguajeResorces](2,'Disclaimer3')
	,@DisclaimerES07=[dbo].[GetMessageFromMultiLenguajeResorces](2,'Disclaimer7')
	
	declare  @AgentState varchar(10)
	declare  @IdAgent int
	SELECT @IdAgent = t.IdAgent, @AgentState = AgentState FROM Regalii.TransferR t WITH (NOLOCK) inner join Agent a WITH (NOLOCK) on a.IdAgent= t.IdAgent where IdProductTransfer=@IdProductTransfer

	declare @lenguage1 int
	declare @lenguage2 int

	select @lenguage1=idlenguage from countrylenguage WITH (NOLOCK) where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryUSA'))
	select @lenguage2=idlenguage from countrylenguage WITH (NOLOCK) where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryMexico'))

	SELECT 
	@AffiliationNoticeEnglish = ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),''), 
	@ComplaintNoticeEnglish = ComplaintNoticeEnglish, 
	@AffiliationNoticeSpanish = ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),''), 
	@ComplaintNoticeSpanish = ComplaintNoticeSpanish 
	FROM Agent A WITH (NOLOCK) INNER JOIN  [State] S WITH (NOLOCK) ON S.StateCode = A.AgentState INNER JOIN StateNote SN ON SN.IdState = S.IdState WHERE IdAgent = @IdAgent

	select @ReceiptTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferMessage'),   
       @ReceiptTransferSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ReceiptTransferMessage'),
       @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill01'), --M00077-Modif. de Recibos (I)
       @DisclaimerEN02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill02'),
	   @DisclaimerEN03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill03'),
       @DisclaimerEN04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill04'),
       @DisclaimerEN05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill05'),
       @DisclaimerEN06='',--[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer6'),
	   @DisclaimerEN07='',--[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer7'),

	   --@DisclaimerEN08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer8'),

       @DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill01'),
       @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill02'),
       @DisclaimerES03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill03'),
       @DisclaimerES04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill04'),
       @DisclaimerES05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill05'),
       @DisclaimerES06='',--[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer6'),
	   @DisclaimerES07='',--[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer7'),

	   --@DisclaimerES08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8'), --M00077-Modif. de Recibos (F)
	   @DisclaimerFederalEN=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerFederalEN'),
	   @DisclaimerFederalES= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalES') 
	SET @EmphasizedDisclamer = 0


	IF (@AgentState = 'CA')
	BEGIN
		SELECT @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill01CA')
		SELECT @DisclaimerEN02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill02CA')
		SELECT @DisclaimerEN03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill03CA')
		SELECT @DisclaimerEN04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill04CA') --M00077-Modif. de Recibos

	    SELECT @DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill01CA')
		SELECT @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill02CA')
	    SELECT @DisclaimerES03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill03CA')
		SELECT @DisclaimerES04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill04CA') --M00077-Modif. de Recibos
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
       
       @DisclaimerEN01Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer4'), --M00077-Modif. de Recibos
       @DisclaimerEN02Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer2'),
       @DisclaimerEN03Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer3'),
	   --@DisclaimerEN07Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer7'), --M00077-Modif. de Recibos

       @DisclaimerES01Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer4'), --M00077-Modif. de Recibos
       @DisclaimerES02Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer2'),
       @DisclaimerES03Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer3')
	   --@DisclaimerES07Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer7') --M00077-Modif. de Recibos


--- Conversion Hora Local 

Declare @receiptType INT = 3

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
		A.AgentCode+' '+ A.AgentName AgentName,      
		A.AgentAddress,
		A.AgentCity+ ' '+ A.AgentState + ' '+ 
		REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS AgentLocation,
		A.AgentPhone,      
		A.AgentFax,
		@LocalDate PaymentDate,
		U.UserLogin,  
		T.[Country] + ' - ' + T.Name BillerDescription,
		T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName,
		CASE WHEN LEN(ISNULL(T.Account_Number,'')) > 4 THEN			
				REPLICATE('*',LEN(ISNULL(T.Account_Number,''))-4) + RIGHT(ISNULL(T.Account_Number,''),4)
			ELSE ISNULL(T.Account_Number,'')
			END Account_Number,
		convert(bit,0) BillerMaskAccountOnReceipt,
		T.[Amount],
		T.[Fee],
		T.Amount+T.Fee TotalOperation,
		T.IdProductTransfer,
		T.ProviderId,
		T.[Name_On_Account] NameOnAccount,
		T.[RequiresNameOnAccount] RequireNameOnAccount,
		T.[CurrencyName] CurrencyName,
		T.[AmountInMN],
		@ReceiptBillPaymentSpanishMessage ReceiptBillPaymentSpanishMessage,
		@ReceiptBillPaymentEnglishMessage ReceiptBillPaymentEnglishMessage,
		@CancelReceiptBillPaymentSpanishMessage CancelReceiptBillPaymentSpanishMessage,
		@CancelReceiptBillPaymentEnglishMessage CancelReceiptBillPaymentEnglishMessage,
		@CorporationPhone CorporationPhone,
		T.ExRate,
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
		@DisclaimerES06 DisclaimerES06,
        @DisclaimerEn06 DisclaimerEn06,
		@DisclaimerES08 DisclaimerEs08,
        @DisclaimerEN08 DisclaimerEn08,
		'*** ' + @DisclaimerEN07 + '.' DisclaimerEn07,
		'*** ' + @DisclaimerEs07 + '.' DisclaimerEs07,
		@EmphasizedDisclamer as EmphasizedDisclamer,
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
		  + CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' del cliente' AttestMessage,
		  @AgentState AgentState
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
		C.CountryName,
		'USD' OriginalCurrency,
		1 IsInternational,

		@TimeZone TimeZoneAbbr,
		'International Bill Payment'  TypeOfService,
		0 IsDomestic,
		'Cash'  PaymentMethod,
		0 OtherFeeMN,

		CONCAT(
			cu.Address, ', ', 
			cu.City, ' ', 
			cu.State, ' ', 
			REPLACE(STR(isnull(cu.Zipcode,0), 5), SPACE(1), '0')
		) CustomerAddress,  
		cu.CelullarNumber  CustomerCelullarNumber,
		CONCAT(
			@DisclaimerEn01, ' ',
			@DisclaimerEn02, ' ',
			@DisclaimerEn03, ' ',
			@ComplaintNoticeEnglish, ' ',
			'or Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov. ',
			@DisclaimerEn04
		)
		DisclaimerEn,
		@DisclaimerEn05  DisclaimerCAEn,

		CONCAT(
			@DisclaimerES01, '<br>',
			'CFPB Notificaciones al Consumidor.<br>',
			@DisclaimerES02, ' ',
			@DisclaimerES03, ' ',
			@ComplaintNoticeSpanish,
			' o Consumer Financial Protecction Bureau al  855-441-2372, 855-729-2372 (TTY / TDD) www.consumerfinance.gov.<br>',
			@DisclaimerES04
		)  DisclaimerES,
		@DisclaimerES05  DisclaimerCAEs,
		DATEADD(DAY, 2, @LocalDate) DateAvailable,
		'' TextoFiServ,
		@PrintedDate PrintDate
	FROM Regalii.TransferR T WITH(NOLOCK)
		JOIN Agent A WITH(NOLOCK) on A.IdAgent=T.IdAgent     
		JOIN Users U WITH(NOLOCK) on U.IdUser = T.EnterByIdUser 
		JOIN Country C WITH(NOLOCK) ON C.IdCountry = T.IdCountry
		JOIN Customer cu WITH(NOLOCK) ON cu.IdCustomer = T.IdCustomer
	WHERE T.IdProductTransfer=@IdProductTransfer

END

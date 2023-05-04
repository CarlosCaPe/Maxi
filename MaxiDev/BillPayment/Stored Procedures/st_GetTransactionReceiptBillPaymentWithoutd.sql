
CREATE PROCEDURE [BillPayment].[st_GetTransactionReceiptBillPaymentWithoutd](@IdAgent BIGINT)
AS
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search screen billers transaction</Description>

<ChangeLog>
<log Date="10/08/2018" Author="snevarez">Creacion del Store</log>
<log Date="21/12/2022" Author="maprado">Se agrega TimeZoneAbbr y se da formato a Sp</log>
</ChangeLog>
*********************************************************************/
BEGIN
	DECLARE @AffiliationNoticeEnglish AS NVARCHAR(max)
    DECLARE @AffiliationNoticeSpanish AS NVARCHAR(max)
    DECLARE @DisclaimerFederalEN NVARCHAR(max)
    DECLARE @Disclaimer13EN NVARCHAR(max)
    DECLARE @ComplaintNoticeEnglish AS NVARCHAR(max)
    DECLARE @ComplaintNoticeSpanish AS NVARCHAR(max)
    DECLARE @DisclaimerFederalES NVARCHAR(max)
    DECLARE @Disclaimer13ES NVARCHAR(max)
    DECLARE @ReceiptBillPaymentSpanishMessage VARCHAR(max) = (SELECT value FROM   globalattributes WHERE  NAME = 'ReceiptBillPaymentSpanishMessage')
    DECLARE @ReceiptBillPaymentEnglishMessage VARCHAR(max) = (SELECT value FROM   globalattributes WHERE  NAME = 'ReceiptBillPaymentEnglishMessage')
    DECLARE @CancelReceiptBillPaymentSpanishMessage VARCHAR(max) = (SELECT value FROM   globalattributes WHERE  NAME = 'ReceiptBillPaymentCancelSpanishMessage')
    DECLARE @CancelReceiptBillPaymentEnglishMessage VARCHAR(max) = (SELECT value FROM   globalattributes WHERE  NAME = 'ReceiptBillPaymentCancelEnglishMessage')
    DECLARE @CorporationPhone VARCHAR(50) = dbo.Getglobalattributebyname('CorporationPhone');
    DECLARE @DisclaimerES01 NVARCHAR(max)
    DECLARE @DisclaimerES02 NVARCHAR(max)
    DECLARE @DisclaimerES03 NVARCHAR(max)
    DECLARE @DisclaimerES04 NVARCHAR(max)
    DECLARE @DisclaimerES05 NVARCHAR(max)
    DECLARE @DisclaimerES06 NVARCHAR(max)
    DECLARE @DisclaimerES07 NVARCHAR(max)
    DECLARE @DisclaimerES08 NVARCHAR(max)
    DECLARE @DisclaimerEN01 NVARCHAR(max)
    DECLARE @DisclaimerEN02 NVARCHAR(max)
    DECLARE @DisclaimerEN03 NVARCHAR(max)
    DECLARE @DisclaimerEN04 NVARCHAR(max)
    DECLARE @DisclaimerEN05 NVARCHAR(max)
    DECLARE @DisclaimerEN06 NVARCHAR(max)
    DECLARE @DisclaimerEN07 NVARCHAR(max)
    DECLARE @DisclaimerEN08 NVARCHAR(max)
    DECLARE @EmphasizedDisclamer BIT
    DECLARE @ReceiptTransferEnglishMessage VARCHAR(max)
    DECLARE @ReceiptTransferSpanishMessage VARCHAR(max)

    SELECT @DisclaimerEN01 = [dbo].[Getmessagefrommultilenguajeresorces](1, 'Disclaimer1'),
           @DisclaimerEN02 = [dbo].[Getmessagefrommultilenguajeresorces](1, 'Disclaimer2'),
           @DisclaimerEN03 = [dbo].[Getmessagefrommultilenguajeresorces](1, 'Disclaimer3'),
           @DisclaimerEN07 = [dbo].[Getmessagefrommultilenguajeresorces](1, 'Disclaimer7'),
           @DisclaimerES01 = [dbo].[Getmessagefrommultilenguajeresorces](2, 'Disclaimer1'),
           @DisclaimerES02 = [dbo].[Getmessagefrommultilenguajeresorces](2, 'Disclaimer2'),
           @DisclaimerES03 = [dbo].[Getmessagefrommultilenguajeresorces](2, 'Disclaimer3'),
           @DisclaimerES07 = [dbo].[Getmessagefrommultilenguajeresorces](2, 'Disclaimer7')

    DECLARE @AgentState VARCHAR(10)

    --declare  @IdAgent int
    SELECT @AgentState = Agentstate
    FROM   Agent
    WHERE  idagent = @IdAgent

    DECLARE @lenguage1 INT
    DECLARE @lenguage2 INT

    SELECT @lenguage1 = idlenguage
    FROM   Countrylenguage
    WHERE  idcountry = CONVERT(INT, [dbo].[Getglobalattributebyname]('IdCountryUSA'))

    SELECT @lenguage2 = idlenguage
    FROM   countrylenguage
    WHERE  idcountry = CONVERT(INT, [dbo].[Getglobalattributebyname]('IdCountryMexico'))

    SELECT @AffiliationNoticeEnglish = Isnull(Replace(affiliationnoticeenglish, '[Agent]', A.agentname), ''),
           @ComplaintNoticeEnglish = complaintnoticeenglish,
           @AffiliationNoticeSpanish = Isnull(Replace(affiliationnoticeenglish, '[Agent]', A.agentname), ''),
           @ComplaintNoticeSpanish = complaintnoticespanish
    FROM   Agent A
    INNER JOIN [state] S ON S.statecode = A.agentstate
    INNER JOIN statenote SN ON SN.idstate = S.idstate
    WHERE  idagent = @IdAgent
    SELECT @ReceiptTransferEnglishMessage = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'ReceiptTransferMessage'),
		   @ReceiptTransferSpanishMessage = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'ReceiptTransferMessage'),
		   @DisclaimerEN01 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer1'),
		   @DisclaimerEN02 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer2'),
		   @DisclaimerEN03 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer3'),
		   @DisclaimerEN04 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer4'),
		   @DisclaimerEN05 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer5'),
		   @DisclaimerEN06 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer6'),
		   @DisclaimerEN07 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer7'),
		   @DisclaimerEN08 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer8'),
		   @DisclaimerES01 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer1'),
		   @DisclaimerES02 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer2'),
		   @DisclaimerES03 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer3'),
		   @DisclaimerES04 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer4'),
		   @DisclaimerES05 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer5'),
		   @DisclaimerES06 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer6'),
		   @DisclaimerES07 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer7'),
		   @DisclaimerES08 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer8'),
		   @DisclaimerFederalEN = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'DisclaimerFederalEN'),
		   @DisclaimerFederalES = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'DisclaimerFederalES')

	SET @EmphasizedDisclamer = 0

	IF ( @AgentState = 'CA' )
	BEGIN
		SET @AffiliationNoticeEnglish = ''
		SET @AffiliationNoticeSpanish = ''
		SET @EmphasizedDisclamer = 1
		SET @ReceiptTransferEnglishMessage =''
		SET @ReceiptTransferSpanishMessage =''

		SELECT @DisclaimerEN01 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer1Ca')
		SELECT @DisclaimerES01 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer1Ca')
		SELECT @DisclaimerES08 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer8CA')
		SELECT @DisclaimerEN08 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer8CA')
		SELECT @DisclaimerES04 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer4')
		SELECT @DisclaimerES05 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer5')
		SELECT @DisclaimerES06 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer6')
		SELECT @DisclaimerES08 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer8CA')
		SELECT @Disclaimer13EN = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer13ENCa')
		SELECT @Disclaimer13ES = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer13ESCa')
	END

	IF ( @AgentState = 'CO' )
	BEGIN
		SELECT @DisclaimerEN01 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer1Co')
		SELECT @DisclaimerEN08 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer8Ca')
		SELECT @DisclaimerES04 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer4')
		SELECT @DisclaimerES05 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer5')
		SELECT @DisclaimerES06 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer6')
		SELECT @DisclaimerES08 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer8')
		SELECT @DisclaimerES02 = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer2')
	END

	SELECT @DisclaimerFederalEN = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'DisclaimerFederalEN')
	SELECT @DisclaimerFederalES = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'DisclaimerFederalES')

	DECLARE @DisclaimerES01Pre NVARCHAR(max)
	DECLARE @DisclaimerES02Pre NVARCHAR(max)
	DECLARE @DisclaimerES03Pre NVARCHAR(max)
	DECLARE @DisclaimerES07Pre NVARCHAR(max)
	DECLARE @DisclaimerEN01Pre NVARCHAR(max)
	DECLARE @DisclaimerEN02Pre NVARCHAR(max)
	DECLARE @DisclaimerEN03Pre NVARCHAR(max)
	DECLARE @DisclaimerEN07Pre NVARCHAR(max)

	SELECT @DisclaimerEN01Pre = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer1'),
		   @DisclaimerEN02Pre = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer2'),
		   @DisclaimerEN03Pre = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer3'),
		   @DisclaimerEN07Pre = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage1, 'Disclaimer7'),
		   @DisclaimerES01Pre = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer1'),
		   @DisclaimerES02Pre = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer2'),
		   @DisclaimerES03Pre = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer3'),
		   @DisclaimerES07Pre = [dbo].[Getmessagefrommultilenguajeresorces](@lenguage2, 'Disclaimer7')

	SELECT A.agentcode + ' ' + A.agentname AgentName,
		   A.agentaddress,
		   A.agentcity + ' ' + A.agentstate + ' ' + Replace(Str(Isnull(A.agentzipcode, 0), 5), Space(1), '0') AS AgentLocation,
		   A.agentphone,
		   A.agentfax,
		   Getdate() PaymentDate,
		   ' ' UserLogin,
		   ' ' BillerDescription,
		   ' ' CustomerFullName,
		   ' ' Account_Number,
		   CONVERT(BIT, 0) BillerMaskAccountOnReceipt,
		   '0' Amount,
		   '0' Fee,
		   '0' TotalOperation,
		   '0' IdProductTransfer,
		   '0' ProviderId,
		   ' ' NameOnAccount,
		   CONVERT(BIT, 0) RequireNameOnAccount,
		   ' ' CurrencyName,
		   '0' AmountInMN,
		   @ReceiptBillPaymentSpanishMessage ReceiptBillPaymentSpanishMessage,
		   @ReceiptBillPaymentEnglishMessage ReceiptBillPaymentEnglishMessage,
		   @CancelReceiptBillPaymentSpanishMessage CancelReceiptBillPaymentSpanishMessage,
		   @CancelReceiptBillPaymentEnglishMessage CancelReceiptBillPaymentEnglishMessage,
		   @CorporationPhone CorporationPhone,
		   '0' ExRate,
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
		   @EmphasizedDisclamer AS EmphasizedDisclamer,
		   @AffiliationNoticeEnglish AffiliationNoticeEnglish,
		   @AffiliationNoticeSpanish AffiliationNoticeSpanish,
		   @DisclaimerFederalEN DisclaimerFederalEN,
		   @Disclaimer13EN Disclaimer13EN,
		   @ComplaintNoticeEnglish ComplaintNoticeEnglish,
		   @ComplaintNoticeSpanish ComplaintNoticeSpanish,
		   @DisclaimerFederalES DisclaimerFederalES,
		   @Disclaimer13ES  Disclaimer13ES,
		   @ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		   @ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,
		   'I attest to have received $' + CONVERT(NVARCHAR(max), Round((0.0), 2)) + ' from the customer/reconozco haber recibido $' + CONVERT(NVARCHAR(max), Round((0.0), 2)) + ' del cliente' AttestMessage,
		   @AgentState AgentState,
		   0 Tax,
		   CASE A.agentstate
				WHEN 'OK' THEN 'Oklahoma'
				WHEN NULL THEN
				CASE
					WHEN a.agentstate = 'OK' THEN 'Oklahoma'
					WHEN a.agentstate != 'OK' THEN a.agentstate
					ELSE ''
				END
				ELSE agentstate
			END StateTax,
			@DisclaimerES01Pre DisclaimerES01Pre,
			@DisclaimerES02Pre DisclaimerES02Pre,
			@DisclaimerES03Pre DisclaimerES03Pre,
			@DisclaimerES07Pre DisclaimerES07Pre,
			@DisclaimerEN01Pre DisclaimerEN01Pre,
			@DisclaimerEN02Pre DisclaimerEN02Pre,
			@DisclaimerEN03Pre DisclaimerEN03Pre,
			@DisclaimerEN07Pre DisclaimerEN07Pre
	FROM Agent A
	WHERE A.idagent = @IdAgent
END
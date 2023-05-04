
CREATE procedure [BillPayment].[st_GetTransactionReceiptBillPayment](@IdProductTransfer bigint)

as
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search screen billers transaction</Description>

<ChangeLog>
<log Date="10/08/2018" Author="adominguez">Creacion del Store</log>
<log Date="25/09/2018" Author="adominguez">Se modifica el campo de regreso NameOfAccount</log>
<log Date="25/09/2018" Author="adominguez">NameOnAccount</log>
<log Date="26/09/2018" Author="azavala">Add Date Available desc</log>
<log Date="11/03/2019" Author="jmoreno">cambios de FiServ</log>
<log Date="04/04/2019" Author="azavala">set DateAvailable with same day when this is null :: Ref: 05042019_azavala</log>
<log Date="17/09/2019" Author="jdarellano" Name="#1">Se agrega validación para pagos con estatus distinto de "Origin".</log>
<log Date="18/09/2019" Author="bortega">Modificación de Disclamers.:: Ref: M00077-Modif. de Recibos</log>
<log Date="05/04/2021" Author="jcsierra">Se utiliza el texto US Dollars en lugar US DOLLARS en CurrencyName </log>
<log Date="2022/06/21" Author="jcsierra">Se agregan columnas TimeZoneAbbr, TypeOfService, PaymentMethod, OtherFeeMN, CustomerAddress, CustomerCelullarNumber, DisclaimerEn, DisclaimerCAEn, DisclaimerES, DisclaimerCAEs</log>
<log Date="2022/07/04" Author="saguilar">Se agrega funcion para conversion de hora local por agente </log>
<log Date="2022/07/5" Author="jcsierra">Se muestra el dia siguiente a la creacion para el campo DateAvailable</log>
<log Date="2022/07/6" Author="jcsierra">Se realiza Merge entre cambios de recibos y UTC</log>
<log Date="04/11/2022" Author="maprado" name="MP-1311">Cambio de TyC</log>
<log Date="27/04/2023" Author="maprado" name="BM-1246">Cambio de logica de obtencion de TyC Domesticos</log>
</ChangeLog>
*********************************************************************/
BEGIN

	declare @Posting int, @BusinnesDay int, @CutOff varchar(MAX), @DateTransfer datetime, @CutOffTime Datetime, @DateAvailable DateTime, @IdAggregator int
	Select @Posting=case
			When B.Posting='Same Day' then 0 else
			Convert(int,Replace(B.Posting,' Days','')) end,
			@BusinnesDay = P.BusinnesDay, @CutOff=B.CutOffTime, @DateTransfer=T.DateOfCreation, @IdAggregator=B.IdAggregator from BillPayment.TransferR T with(nolock) 
						join BillPayment.Billers B with(nolock) on B.IdBiller=T.IdBiller 
						join BillPayment.Posting P with(nolock) on P.PostingMaxi=B.Posting
						where T.IdProductTransfer=@IdProductTransfer--291827
						
			
set @IdAggregator= (select idAggregator from  Billpayment.Billers with (nolock) where idbiller=(select idbiller from billpayment.TransferR with (nolock) where IdProductTransfeR= @IdProductTransfer))

--IF(@IdAggregator=5)
IF(@IdAggregator=5 and (select IdStatus from billpayment.TransferR with (nolock) where IdProductTransfeR= @IdProductTransfer)!=1)--#1
	begin
		declare 
		@Json nvarchar(max),
		@TextoFiServ nvarchar(max)
		
		set @Json=(select jsonResponse from Billpayment.TransferR with (nolock) where IdProductTransfer=@IdProductTransfer)--291979)
		SELECT StringValue into #FiServTemp FROM fnParseJSON(@json) where Name='receiptMessageLine'		
		SELECT @TextoFiServ= COALESCE(@TextoFiServ + ', ', '') + StringValue FROM #FiServTemp
		set @TextoFiServ = Replace(@TextoFiServ, '<BR/>',' ') 
		drop table #FiServTemp
	end
	
							

	IF(@IdAggregator=5)
		BEGIN
			if(@DateTransfer>=@CutOffTime)
			begin
				Select @DateTransfer=DATEADD(d,1,@DateTransfer)
			end
		END
	ELSE
		BEGIN
			SET @CutOff=(select Replace(REPLACE(@CutOff,' CST',''),' pm','PM'))
			IF(LEN(@CutOff)=6)
				set @CutOff = '0'+@CutOff
			set @CutOffTime = dbo.RemoveTimeFromDatetime (@DateTransfer);

			IF CHARINDEX('PM',@CutOff) > 0
				begin
					select @CutOffTime=DATEADD(hh,convert(int,(Left(@CutOff,2)))+12, @CutOffTime)
					select @CutOffTime=DATEADD(mi,convert(int,(Right(replace(@CutOff,'PM',''),2))), @CutOffTime)
				end
			ELSE
				begin
					select @CutOffTime=DATEADD(hh,convert(int,(Left(@CutOff,2))), @CutOffTime)
					select @CutOffTime=DATEADD(mi,convert(int,(Right(replace(@CutOff,'PM',''),2))), @CutOffTime)
				end

		--	Select @CutOffTime as cutooftime
			if(@DateTransfer>=@CutOffTime)
			begin
				Select @DateTransfer=DATEADD(d,1,@DateTransfer)
			end
		END

	if(@BusinnesDay=1)
		begin
			dECLARE @count int, @Days varchar(MAX)
			Set @count=1
			--SET @Posting=3
			SET @Days=''

			IF DATENAME(DW, @DateTransfer) = 'sunday'   SET @DateTransfer = DATEADD(d, 1, @DateTransfer)
			IF DATENAME(DW, @DateTransfer) = 'saturday' SET @DateTransfer = DATEADD(d, 2, @DateTransfer)
			set @DateAvailable = @DateTransfer
			while(@count<=@Posting)
				begin
					Select @DateAvailable=DATEADD(d,1,@DateAvailable)
					set @Days = @Days + (Select Convert(varchar,dbo.GetDayOfWeek (@DateAvailable))+',')
					set @count=@count+1;
				end
			if(@Days like '%6%' and @Days like '%7%')
				begin
					Select @DateAvailable=DATEADD(d,2,@DateAvailable)
				end
			else
				begin
					IF(@Days like '%6%')
						Select @DateAvailable=DATEADD(d,2,@DateAvailable)

					IF(@Days like '%7%')
						Select @DateAvailable=DATEADD(d,1,@DateAvailable)
				end
			end
		ELSE
			Begin
				if(@Posting=0)
					begin
						Set @DateAvailable=@DateTransfer
					end
				else
					begin
						SET @DateAvailable = DATEADD(d,@Posting,@DateTransfer)
					end
		End

	DECLARE @AffiliationNoticeEnglish NVARCHAR(MAX) 

	DECLARE @AffiliationNoticeSpanish NVARCHAR(MAX) 

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

	@DisclaimerEN07='',--[dbo].[GetMessageFromMultiLenguajeResorces](1,'Disclaimer7'),

	@DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](2,'Disclaimer1'),

    @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](2,'Disclaimer2'),

    @DisclaimerES03=[dbo].[GetMessageFromMultiLenguajeResorces](2,'Disclaimer3')

	,@DisclaimerES07='' --[dbo].[GetMessageFromMultiLenguajeResorces](2,'Disclaimer7')

	

	declare  @AgentState varchar(10)

	declare  @IdAgent int

	SELECT @IdAgent = t.IdAgent, @AgentState = AgentState FROM BillPayment.TransferR t WITH (NOLOCK) inner join Agent a WITH (NOLOCK) on a.IdAgent= t.IdAgent where IdProductTransfer=@IdProductTransfer



	declare @lenguage1 int

	declare @lenguage2 int



	select @lenguage1=idlenguage from countrylenguage WITH (NOLOCK) where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryUSA'))

	select @lenguage2=idlenguage from countrylenguage WITH (NOLOCK) where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryMexico'))



	SELECT 

	@AffiliationNoticeEnglish = ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),''), 

	@ComplaintNoticeEnglish = ComplaintNoticeEnglish, 

	@AffiliationNoticeSpanish = ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),''), 

	@ComplaintNoticeSpanish = ComplaintNoticeSpanish 

	FROM Agent A WITH (NOLOCK) INNER JOIN  [State] S WITH (NOLOCK) ON S.StateCode = A.AgentState INNER JOIN StateNote SN WITH (NOLOCK) ON SN.IdState = S.IdState WHERE IdAgent = @IdAgent


	select @ReceiptTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferMessage'),   

       @ReceiptTransferSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ReceiptTransferMessage'),

       @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill01'), --M00077-Modif. de Recibos()

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

       @DisclaimerES05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill05'), --M00077-Modif. de Recibos()

       @DisclaimerES06='',--[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer1Ca'),

	   @DisclaimerES07='',

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


select --@PreTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'PreTransferMessage'),
       --@PreTransferSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'PreTransferMessage'),
       @DisclaimerEN01Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer4'), --M00077-Modif. de Recibos() 
       @DisclaimerEN02Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer2'),
       @DisclaimerEN03Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer3'),
	   @DisclaimerEN07Pre='' ,--[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer7'),

       @DisclaimerES01Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer4'),
       @DisclaimerES02Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer2'),
       @DisclaimerES03Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer3'),
	   @DisclaimerES07Pre='' --[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer7') --M00077-Modif. de Recibos()





--- Conversion Hora Local 

Declare @receiptType INT = 2

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
		--case when @DateAvailable is null then CONVERT(date, GetDate()) else CONVERT(date, @DateAvailable) end as DateAvailable, --05042019_azavala
		DATEADD(DAY, 1, @LocalDate) DateAvailable,
		A.AgentPhone,      
		A.AgentFax,
		@LocalDate PaymentDate,
		U.UserLogin,  
		T.[Country] + ' - ' + T.Name BillerDescription,
		T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName,

		CASE 
		When (select CategoryAggregator from BillPayment.Billers With (nolock)  where idbiller= T.idbiller and IdAggregator= 5) <> 'Credit Cards'
      then 
		   ISNULL(T.Account_Number,'')
		
		WHEN LEN(ISNULL(T.Account_Number,'')) > 4 THEN			

				REPLICATE('*',LEN(ISNULL(T.Account_Number,''))-4) + RIGHT(ISNULL(T.Account_Number,''),4)

			ELSE ISNULL(T.Account_Number,'')

			END Account_Number,

		convert(bit,0) BillerMaskAccountOnReceipt,
		T.[Amount],
		T.[Fee],
		T.Amount+T.Fee TotalOperation,
		T.IdProductTransfer,
		T.TraceNumber ProviderId,
		T.[Name_On_Account] NameOnAccount,
		T.[RequiresNameOnAccount] RequireNameOnAccount,
		CASE WHEN T.[CurrencyName] = 'US DOLLARS' THEN 'USD' ELSE T.CurrencyName END CurrencyName,
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
		@DisclaimerEN07 DisclaimerEn07,--'*** ' + @DisclaimerEN07 + '.' DisclaimerEn07,
		@DisclaimerEs07 DisclaimerEs07,--'*** ' + @DisclaimerEs07 + '.' DisclaimerEs07,

		@EmphasizedDisclamer as EmphasizedDisclamer,
		@AffiliationNoticeEnglish as AffiliationNoticeEnglish,
		@AffiliationNoticeSpanish as AffiliationNoticeSpanish,
		(SELECT REPLACE(@DisclaimerFederalEN,', ',' '))  DisclaimerFederalEN,  --M00077-Modif. de Recibos
		@Disclaimer13EN Disclaimer13EN,
		@ComplaintNoticeEnglish ComplaintNoticeEnglish,
		@ComplaintNoticeSpanish ComplaintNoticeSpanish,
		@DisclaimerFederalES DisclaimerFederalES,  --M00077-Modif. de Recibos
		@Disclaimer13ES Disclaimer13ES,
		@ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		@ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,
		'I attest to have received $'+ CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' from the customer/reconozco haber recibido $' + CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' del cliente' AttestMessage,
		@AgentState AgentState,
		@DisclaimerES01Pre DisclaimerES01Pre,
		@DisclaimerES02Pre DisclaimerES02Pre,
		@DisclaimerES03Pre DisclaimerES03Pre,
		@DisclaimerES07Pre DisclaimerES07Pre,
		@DisclaimerEN01Pre DisclaimerEN01Pre,
		@DisclaimerEN02Pre DisclaimerEN02Pre,
		@DisclaimerEN03Pre DisclaimerEN03Pre,
		@DisclaimerEN07Pre DisclaimerEN07Pre,
		TextoFiServ = '',

		@TimeZone TimeZoneAbbr,
		'Domestic Bill Payment (Dollar to Dollar)'  TypeOfService,
		1 IsDomestic,
		'Cash'  PaymentMethod,
		0 OtherFeeMN,

		CONCAT(
			c.Address, ', ', 
			c.City, ' ', 
			c.State, ' ', 
			REPLACE(STR(isnull(c.Zipcode,0), 5), SPACE(1), '0')
		) CustomerAddress,  
		c.CelullarNumber  CustomerCelullarNumber,
		[dbo].[fn_GetTyC] (1,1,1) DisclaimerEn,
		IIF (@AgentState = 'CA',
			[dbo].[fn_GetTyC] (1,0,1),
			@DisclaimerEn05
		) DisclaimerCAEn,
		[dbo].[fn_GetTyC] (1,1,2) DisclaimerES,
		IIF (@AgentState = 'CA',
			[dbo].[fn_GetTyC] (1,0,2),
			@DisclaimerES05
		) DisclaimerCAEs,
		T.Country CountryName,
		0 IsInternational,
		T.CurrencyName OriginalCurrency,
		0 Tax,
		Case A.AgentState When 'OK' Then 'Oklahoma' When NULL Then case when a.agentstate='OK' Then 'Oklahoma' when a.agentstate!='OK' Then a.agentstate else ''END Else  AgentState End StateTax,
		@PrintedDate PrintDate
	FROM BillPayment.TransferR T WITH(NOLOCK)
		JOIN Agent A WITH(NOLOCK) ON A.IdAgent=T.IdAgent
		JOIN Users U WITH(NOLOCK) ON U.IdUser = T.EnterByIdUser 
		JOIN Customer c WITH(NOLOCK) ON c.IdCustomer = T.IdCustomer
	WHERE T.IdProductTransfer=@IdProductTransfer
END
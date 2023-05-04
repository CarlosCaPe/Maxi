
CREATE procedure [dbo].[st_GetTransactionReceipt] 
(	@IdTransfer int,
	@IdCountryOrigin int,
	@IdCountryDestiny int
) AS

/********************************************************************
exec [st_GetTransactionReceipt] 9984553,18,3 --CO
exec [st_GetTransactionReceipt] 9984555,18,3 --TX
exec [st_GetTransactionReceipt] 9984559,18,3 --CA
<Author> ??? </Author>
<app> Agent, Corporative </app>
<Description> Gets print information for Tickets and Recepits</Description>

<ChangeLog>
<log Date="19/05/2017" Author="fgonzalez">Gets Disclamer text from customer state instead of Agent´s</log>
<log Date="20/09/2017" Author="jmoreno">California Disclamer.</log>
<log Date="11/09/2017" Author="jmoreno">Se modifica Disclamer.</log>
<log Date="18/10/2017" Author="jvelarde">Se agrega funcion para calcular el tax cuando no lo trae.</log>
<log Date="07/02/2018" Author="mhinojo">Ajustes para reportes, leyendas en portugues.</log>
<log Date="07/02/2018" Author="fdiaz">Datos BeneficiaryMirror.</log>
<log Date="07/02/2018" Author="esalazar"> BeneficiaryMirror CellPhoneNumber</log>
<log Date="06/11/2018" Author="snevarez"> ticket 1523:Mantis 0001537 - Add round</log>
<log Date="25/03/2019" Author="jmolina">Ajuste en busqueda de Estado de agencía para reimpresiones</log>
<log Date="08/08/2019" Author="jdarellano" Name="#1">Modificación por solicitud sobre disclaimer de "StateNote", de Customer a Agent.</log>
<log Date="14/09/2018" Author="jresendiz">Se agrega validación para lenguaje portugues</log>
<log Date="18/09/2019" Author="bortega">Modificación de Disclamers. :: Ref: M00077-Modif. de Recibos</log>
<log Date="23/02/2020" Author="adominguez" Name"#2">Se agrega Direccion del branch y se ajusta longitud de campos para que no sobrepasen mas de 1 renglon en recibo RDL</log>
<log Date="09/11/2020" Author="adominguez"> M00056 : Modificaiones</log>
<log Date="04/12/2020" Author="adominguez"> M00056 : Modificaiones - Fix Folio TM</log>
<log Date="19/04/2021" Author="jcsierra"> Se ocultan los datos demograficos del beneficiario cuando es deposito </log>
<log Date="25/11/2021" Author="saguilar"> Se agrega conversion de la fecha y hora de transaccion a la hora local por agencia </log>
<log Date="24/01/2022" Author="jcsierra">Add PosTransfer props</log>
<log Date="11/05/2022" Author="jcsierra">Add OtherFeeMN Column</log>
<log Date="21/06/2022" Author="jcsierra">Fix BeneficiaryAddress Column</log>
<log Date="21/06/2022" Author="jcsierra">Correccion en las columnas DisclaimerCAEn, DisclaimerCAEs y se omite el @lenguage2 en caso que sea USA</log>
<log Date="28/06/2022" Author="jcsierra">Se considera Discount en la columna de Fee</log>
<log Date="19/07/2022" Author="jcsierra">Cambios en BeneficiaryAddress</log>
<log Date="19/09/2022" Author="jcsierra" name="MP-1268">Se corrige la leyenda de recibir SMS's</log>
<log Date="04/11/2022" Author="maprado" name="MP-1311">Cambio de TyC</log>
<log Date="09/11/2022" Author="maprado" name="M1-272">Se agrega IdAgent</log>
<log Date="08/12/2022" Author="maprado" name="M1-272">Se considera @IdCountryIDN para no mostrar TyC en esp</log>
<log Date="30/01/2023" Author="maprado" name="BM-773">Se realiza correccion de asignacion de @IdCountryPHL, @IdCountryVNM, @IdCountryIDN para no mostrar TyC en esp</log>
<log Date="14/02/2023" Author="maprado" name="BM-772">Se realiza correccion de asignacion de @IdCountryPHL, @IdCountryVNM, @IdCountryIDN ya que estaban dentro de IF</log>
<log Date="17/02/2023" Author="maprado" name="BM-1040">Se realiza correccion de datos demograficos de beneficiario cuando es IdPaymentType = Deposit</log>
<log Date="10/03/2023" Author="maprado" name="">Ticket 7836 - Se realiza correccion de StateTax, se agrega ISNULL</log>
<log Date="22/03/2023" Author="maprado" name="">BM-1221 - Se realiza cambio en logica de obtencion de TyC para envios domesticos</log>
</ChangeLog>

*********************************************************************/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @InterCode NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('InfiniteCountryCode')
declare @isAgentCA bit


--fgonzalez
DECLARE @BoldDisclamerStates Table (AgentState VARCHAR(10))
INSERT INTO  @BoldDisclamerStates VALUES ('CA')


declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');   

--dia de cobro
declare @TimeForClaimTransfer varchar(50)
set @TimeForClaimTransfer = [dbo].[GetGlobalAttributeByName]('TimeForClaimTransfer') 

declare @DayOfWeek int
set @DayOfWeek = [dbo].[GetDayOfWeek](getdate())

--get lenguage resource
declare @lenguage1 int
declare @lenguage2 int

select @lenguage1=idlenguage from countrylenguage WITH (NOLOCK) where idcountry=@IdCountryOrigin
if @lenguage1 is null
begin    
    select @lenguage1=idlenguage from countrylenguage WITH (NOLOCK) where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryUSA'))
end

select @lenguage2=idlenguage from countrylenguage WITH (NOLOCK) where idcountry=@IdCountryDestiny AND IdCountry <> convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryUSA'))
if @lenguage2 is null
begin    
    select @lenguage2=idlenguage from countrylenguage WITH (NOLOCK) where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryMexico'))
end


declare @IdCountryCurrencyMexicoPesos int= [dbo].[GetGlobalAttributeByName]('IdCountryCurrencyMexicoPesos')
--select @lenguage1,@lenguage2

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
declare @DisclaimerFederalES nvarchar(max)
declare @Disclaimer13ES nvarchar(max)

declare @DisclaimerEN01 nvarchar(max)
declare @DisclaimerEN02 nvarchar(max)
declare @DisclaimerEN03 nvarchar(max)
declare @DisclaimerEN04 nvarchar(max)
declare @DisclaimerEN05 nvarchar(max)
declare @DisclaimerEN06 nvarchar(max)
declare @DisclaimerEN07 nvarchar(max)

declare @DisclaimerEN08 nvarchar(max)
declare @DisclaimerFederalEN nvarchar(max)
declare @Disclaimer13EN nvarchar(max)

declare @BonusMessage  nvarchar(max)


Declare @Disclaimer09EN nvarchar(max) --M00077-Modif. de Recibos
Declare @Disclaimer09ES nvarchar(max)
Declare @Disclaimer10EN nvarchar(max)
Declare @Disclaimer10ES nvarchar(max)
Declare @Disclaimer11PO nvarchar(max)
Declare @Disclaimer12PO nvarchar(max)
Declare @Disclaimer13PO nvarchar(max) --M00077-Modif. de Recibos


declare  @AgentStateCa varchar(10)

set @AgentStateCa = (SELECT A.AgentState FROM [Transfer] T WITH (NOLOCK) INNER JOIN Agent A WITH (NOLOCK) ON T.IdAgent = A.IdAgent WHERE T.IdTransfer= @IdTransfer) 

if (@AgentStateCa='' OR @AgentStateCa is null)
begin
	set @AgentStateCa = (SELECT A.AgentState FROM [TransferClosed] T WITH (NOLOCK) INNER JOIN Agent A with(nolock) ON T.IdAgent = A.IdAgent WHERE T.IdTransferClosed= @IdTransfer) 
end

-----mensajes
 
   
select @ReceiptTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferMessage'),   
       @ReceiptTransferSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ReceiptTransferMessage'),
       @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer10'), --M00077-Modif. de Recibos()
       @DisclaimerEN02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer4'),
       @DisclaimerEN03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer5'),
       @DisclaimerEN04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer6') ,
       @DisclaimerEN05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer9'),
       @DisclaimerEN06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1Ca'),
	   --@DisclaimerEN07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1Ca'),

	   @DisclaimerEN08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer8'),

       @DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10'),
       @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer4'),
       @DisclaimerES03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer5'),
       @DisclaimerES04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer6'),
       @DisclaimerES05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer9'),
       @DisclaimerES06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer1Ca'),
	   @DisclaimerES07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer7'),

	   @DisclaimerES08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8'),
	   @DisclaimerFederalEN=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerFederalEN'),
	   @DisclaimerFederalES= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalPOR') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalES') END,

       @BonusMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'PMBonification'),
	@Disclaimer09EN =[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer9'),
	@Disclaimer09ES =[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer9'),
	@Disclaimer10EN =[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer10'),
	@Disclaimer10ES =[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10')


	IF @lenguage2 = 3 
	BEGIN	
		select  @DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer14'),
       @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer11Ca'),
       @DisclaimerES03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer12Ca'),
       @DisclaimerES04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer13PORCa'),
       @DisclaimerES05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer13Ca'),
       @DisclaimerES06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer15'),
	   @DisclaimerES07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10'), --M00077-Modif. de Recibos()

	   @DisclaimerES08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10CA'),
	   --@DisclaimerFederalEN=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerFederalEN'),
	   @DisclaimerFederalES= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalPOR'),
	   @ReceiptTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferMessagePortugues')
	   --@Disclaimer11PO =[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer14'),
	   --@Disclaimer12PO =[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer15')
		--Select @Disclaimer13PO =[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer9')
	END

  
Declare @Resend bit  
Set @Resend=1  
Declare @NotResend bit  
Set @NotResend=0  
Declare @ComprobanteMessage int 
set @ComprobanteMessage=0
Declare @IdTransferModify int
set @IdTransferModify =0


set @AgentStateCa = (SELECT A.AgentState FROM [Transfer] T WITH (NOLOCK) INNER JOIN Agent A ON T.IdAgent = A.IdAgent WHERE T.IdTransfer= @IdTransfer) 

if (@AgentStateCa='' OR @AgentStateCa is null)
begin
	set @AgentStateCa = (SELECT A.AgentState FROM [TransferClosed] T WITH (NOLOCK) INNER JOIN Agent A with(nolock) ON T.IdAgent = A.IdAgent WHERE T.IdTransferClosed= @IdTransfer) 
end

IF(@AgentStateCa = 'CA') --M00077-Modif. de Recibos
BEGIN
	SELECT @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer10CA')
	SELECT @DisclaimerEN02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer11CA')
	SELECT @DisclaimerEN05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer9CA') 

	SELECT @DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10CA')
	SELECT @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer11CA')
	SELECT @DisclaimerES05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer9CA')
END
ELSE
BEGIN
	SET @DisclaimerES06 = ''
	SET @DisclaimerEN06 = ''
END

SELECT @DisclaimerFederalEN=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerFederalEN')
SELECT @DisclaimerFederalES= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalPOR') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalES') END


 
--BeneficiaryMirror
declare @TopBeneficiaryMirrorid int
declare @BeneficiaryMirrorFullName nvarchar(max)
declare @BeneficiaryMirrorAddress nvarchar(max)
declare @BeneficiaryMirrorLocation nvarchar(max)
declare @BeneficiaryMirrorPhoneNumber nvarchar(max)
declare @BeneficiaryMirrorCellPhoneNumber nvarchar(max)
declare @BeneficiaryMirrorCountry nvarchar(max)

IF exists(Select 1 from BeneficiaryMirror WITH (NOLOCK) where IdTransfer = @IdTransfer)
	BEGIN
		select @TopBeneficiaryMirrorid = max(IdBeneficiaryMirror) from BeneficiaryMirror WITH (NOLOCK) where IdTransfer = @IdTransfer; 

		select top 1 @BeneficiaryMirrorFullName = B.Name + ' ' + B.FirstLastName + ' ' + B.SecondLastName, 
					 @BeneficiaryMirrorAddress = B.Address,
					 @BeneficiaryMirrorLocation = case       
												   when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode      
												   else B.City+' '+B.State+' '+B.Zipcode   
												  end ,
					 @BeneficiaryMirrorPhoneNumber = B.PhoneNumber, 
					 @BeneficiaryMirrorCellPhoneNumber = B.CelullarNumber,
					 @BeneficiaryMirrorCountry = B.Country 
					 from BeneficiaryMirror  B WITH (NOLOCK)
					 inner join Transfer T with(nolock) on T.IdTransfer = B.IdTransfer
					 left join Branch Br WITH (NOLOCK) on Br.IdBranch = T.IdBranch   
					 left join City BrC WITH (NOLOCK) on BrC.IdCity = Br.IdCity      
					 left join State BrS WITH (NOLOCK) on BrS.IdState = BrC.IdState    
					 where B.IdTransfer = @IdTransfer
					 and B.IdBeneficiaryMirror = @TopBeneficiaryMirrorid; 
	END
ELSE
	BEGIN
		set @BeneficiaryMirrorFullName = NULL
		set @BeneficiaryMirrorAddress = NULL
		set @BeneficiaryMirrorLocation = NULL
		set @BeneficiaryMirrorPhoneNumber = NULL
		set @BeneficiaryMirrorCellPhoneNumber = NULL
		set @BeneficiaryMirrorCountry = NULL
	END 

IF EXISTS(SELECT 1 FROM TransferModify WITH (NOLOCK) WHERE NewIdTransfer = @IdTransfer) 
BEGIN
	select @IdTransferModify = OldIdTransfer from TransferModify WITH (NOLOCK) where NewIdTransfer = @IdTransfer
	select @TopBeneficiaryMirrorid = max(IdBeneficiaryMirror) from BeneficiaryMirror WITH (NOLOCK) where IdTransfer = @IdTransferModify; 

	select top 1 @BeneficiaryMirrorFullName = B.Name + ' ' + B.FirstLastName + ' ' + B.SecondLastName, 
					@BeneficiaryMirrorAddress = B.Address,
					--@BeneficiaryMirrorLocation = City + ' ' + State + ' ' + Zipcode,
					@BeneficiaryMirrorLocation = case       
												when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode      
												else B.City+' '+B.State+' '+B.Zipcode   
												end ,
					@BeneficiaryMirrorPhoneNumber = B.PhoneNumber, 
					@BeneficiaryMirrorCellPhoneNumber = B.CelullarNumber,
					@BeneficiaryMirrorCountry = B.Country 
					from BeneficiaryMirror  B WITH (NOLOCK)
					inner join Transfer T with(nolock) on T.IdTransfer = B.IdTransfer
					left join Branch Br WITH (NOLOCK) on Br.IdBranch = T.IdBranch   
					left join City BrC WITH (NOLOCK) on BrC.IdCity = Br.IdCity      
					left join State BrS WITH (NOLOCK) on BrS.IdState = BrC.IdState 
					where B.IdTransfer = @IdTransferModify
					and B.IdBeneficiaryMirror = @TopBeneficiaryMirrorid; 
END


IF(@BeneficiaryMirrorCellPhoneNumber = NULL) 
BEGIN
SET @BeneficiaryMirrorCellPhoneNumber=@BeneficiaryMirrorPhoneNumber
END
ELSE
BEGIN
SET @BeneficiaryMirrorPhoneNumber=@BeneficiaryMirrorCellPhoneNumber
END
 
  
DECLARE @HideCityAndStatePaymentType TABLE (Id INT) 
INSERT INTO @HideCityAndStatePaymentType
VALUES (2)


DECLARE @LabelReplaceFolio						NVARCHAR(MAX),
		@ModificationLabelNewFolio				NVARCHAR(MAX),
		@ModificationLabelNewFolio_Spanish		NVARCHAR(MAX),
		@ShowModificationLabel					BIT = 0,
		@IsChangeRequest						BIT = 0

SET @LabelReplaceFolio = CONCAT(dbo.GetMessageFromMultiLenguajeResorces(1, 'LabelReplaceFolio'), ' / ', dbo.GetMessageFromMultiLenguajeResorces(2, 'LabelReplaceFolio'))
SET @ModificationLabelNewFolio = dbo.GetMessageFromMultiLenguajeResorces(1, 'ModificationLabelNewFolio')
SET @ModificationLabelNewFolio_Spanish = dbo.GetMessageFromMultiLenguajeResorces(2, 'ModificationLabelNewFolio')

IF EXISTS(SELECT 1 FROM TransferModify tm WITH (NOLOCK) WHERE tm.NewIdTransfer = @IdTransfer)
BEGIN
	SET @IsChangeRequest = 1

	IF EXISTS(SELECT 1 FROM TransferModify tm WITH (NOLOCK) JOIN TransferDetail td ON td.IdTransfer = tm.OldIdTransfer WHERE tm.NewIdTransfer = @IdTransfer AND td.IdStatus IN (21, 23))
		SET @ShowModificationLabel = 1
END

IF ISNULL(@BeneficiaryMirrorFullName, '') <> ''
BEGIN
	SET @IsChangeRequest = 1

	SET @BeneficiaryMirrorFullName = NULL
	SET @BeneficiaryMirrorAddress = NULL
	SET @BeneficiaryMirrorLocation = NULL
	SET @BeneficiaryMirrorPhoneNumber = NULL
	SET @BeneficiaryMirrorCellPhoneNumber = NULL
	SET @BeneficiaryMirrorCountry = NULL
END

DECLARE @IdCountryUSA	INT,
		@IdCurrencyUSA	INT,
		@IdCountryPHL	INT,
		@IdCountryVNM	INT,
		@IdCountryIDN	INT

SET @IdCountryUSA = dbo.GetGlobalAttributeByName('IdCountryUSA')
SET @IdCurrencyUSA = dbo.GetGlobalAttributeByName('IdCurrencyUSA')
SET @IdCountryPHL = dbo.GetGlobalAttributeByName('IdCountryPHL')
SET @IdCountryVNM = dbo.GetGlobalAttributeByName('IdCountryVNM')
SET @IdCountryIDN = dbo.GetGlobalAttributeByName('IdCountryIDN')
 
If exists(Select 1 from Transfer WITH (NOLOCK) where IdTransfer=@IdTransfer)    
Begin
		set @ComprobanteMessage= (select top 1 1 from BrokenRulesByTransfer WITH (NOLOCK) where IdTransfer=@IdTransfer and IdKYCAction=4 and MessageInSpanish like '%comprobante de ingresos%' )

		/*---- Modificaiones - Fix Folio TM - Begin ----*/
		DECLARE @TransferTmp TABLE
		(
			IdTransfer INT,
			Folio INT,
			IdStatus INT
		)

		IF EXISTS(SELECT 1 FROM TransferModify AS TM WITH(NOLOCK) WHERE TM.NewIdTransfer = @IdTransfer)
		BEGIN
			
			Insert Into @TransferTmp (IdTransfer,Folio, IdStatus)
				Select 
					T.IdTransfer
					, T.Folio
					, T.IdStatus
				From Transfer AS T WITH (NOLOCK)
					Inner Join TransferModify AS TM WITH(NOLOCK) ON T.IdTransfer = TM.OldIdTransfer
				Where NewIdTransfer = @IdTransfer

			Insert Into @TransferTmp (IdTransfer,Folio, IdStatus)
				Select 
					T.IdTransferClosed AS IdTransfer
					, T.Folio
					, T.IdStatus
				From TransferClosed AS T WITH (NOLOCK)
						Inner Join TransferModify AS TM WITH(NOLOCK) ON T.IdTransferClosed = TM.OldIdTransfer
				Where TM.NewIdTransfer = @IdTransfer
			
		END
		/*---- Modificaiones - Fix Folio TM - End ----*/



		

--- Conversion Hora Local Transfer

Declare @receiptType bit = 0

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

--- Termina Conversion

		Select
			@CorporationPhone CorporationPhone,      
			@CorporationName CorporationName,    
			@ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
			@ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,  
			A.AgentCode+' '+ A.AgentName AgentName,    
			A.AgentAddress AgentAddress,      
			A.AgentCity+ ' '+ A.AgentState + ' '+ 
			REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS AgentLocation,
			A.AgentPhone,      
			T.Folio,
			(SELECT TOP 1 CAST(Folio AS VARCHAR) FROM @TransferTmp WHERE IdTransfer = TM.OldIdTransfer) FolioTM, /*Modificaiones - Fix Folio TM*/
			U.UserLogin,      
			@LocalDate as DateOfTransfer,        
			T.ClaimCode,      
			T.IdCustomer,      
			T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName,
			CONCAT(
				T.CustomerAddress, ', ', 
				T.CustomerCity, ' ', 
				T.CustomerState, ' ', 
				REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0')
			) CustomerAddress,      
			T.CustomerCity+' '+ T.CustomerState+' '+
			REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') AS  CustomerLocation,      
			T.CustomerPhoneNumber,  
			T.CustomerCelullarNumber,
			CASE WHEN CN.[AllowSentMessages] = 1 THEN 'YES' ELSE 'NO' END [CustomerReceiveMessage],
			T.BeneficiaryName+' '+T.BeneficiaryFirstLastName+' '+ T.BeneficiarySecondLastName BeneficiaryFullName, 
			LTRIM(
				IIF((EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = T.IdPaymentType) AND ISNULL(T.BeneficiaryAddress, '') = ''), --SI ES IdPaymentType = DEPOSITO MOSTRAR SOLO PAIS BM-1040
					CASE 
						WHEN ISNULL(T.BeneficiaryCountry, '') <> '' THEN T.BeneficiaryCountry
						WHEN BrCt.IdCountry IS NOT NULL THEN BrCt.CountryName
						ELSE CCo.CountryName
					END,
					CONCAT(
						IIF(ISNULL(T.BeneficiaryAddress, '') <> '', CONCAT(T.BeneficiaryAddress, ', ', T.BeneficiaryCity), ''),
						' ',
						CASE 
							WHEN ISNULL(T.BeneficiaryState, '') <> '' THEN CONCAT( T.BeneficiaryState, ', ')
							WHEN ISNULL(BrS.StateName, '') <> '' THEN CONCAT(BrS.StateName, ', ')
							ELSE NULL
						END,
						CASE 
							WHEN ISNULL(T.BeneficiaryCountry, '') <> '' THEN T.BeneficiaryCountry
							WHEN BrCt.IdCountry IS NOT NULL THEN BrCt.CountryName
							ELSE CCo.CountryName
						END
					)
				)
			) BeneficiaryAddress,   
			case
			WHEN EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) AND T.BeneficiaryCity='' THEN BrCt.CountryName
			when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode + ' ' + BrCt.CountryName 
			else B.City+' '+B.State+' '+B.Zipcode + ' ' + BrCt.CountryName
			end BeneficiaryLocation,
			case
		  	WHEN EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) AND T.BeneficiaryCity='' THEN BrCt.CountryName
			when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName      
			else B.City+' '+B.State   
			end BeneficiaryOnlyCityState, --M00077-Modif. de Recibos
			--BrC.CityName+' '+ BrS.StateName BeneficiaryOnlyCityState, 
			Cco.CountryName CountryName,
			T.BeneficiaryCelularNumber AS BeneficiaryPhoneNumber,
			T.BeneficiaryCelularNumber,      
			T.BeneficiaryCountry,
			--Prueba Beneficiary Mirror
			@BeneficiaryMirrorFullName BeneficiaryMirrorFullName,
			@BeneficiaryMirrorAddress BeneficiaryMirrorAddress,
			@BeneficiaryMirrorLocation BeneficiaryMirrorLocation, 
			@BeneficiaryMirrorPhoneNumber BeneficiaryMirrorPhoneNumber,
			@BeneficiaryMirrorCellPhoneNumber BeneficiaryMirrorCellPhoneNumber,
			@BeneficiaryMirrorCountry BeneficiaryMirrorCountry,
			--Termina prueba Beneficiary Mirror   
			Py.PaymentName,      
			T.AmountInDollars,      
			T.Fee - T.Discount Fee,      

		--T.ExRate,  
		  ROUND(T.ExRate,2) AS ExRate, /*ticket 1523:Mantis 0001537*/

		  P.PayerName,      
		  GB.GatewayBranchCode,      
		  CASE 
			WHEN CCu.CurrencyCode = 'MXP' THEN 'MXN' 
			--WHEN (CC.IdCountry = @IdCountryUSA) THEN 'US'
			ELSE CCu.CurrencyCode 
		  END AS CurrencyCode,      
		  T.AmountInMN,   
		  0.0 OtherFeeMN,
		  CCo.CountryName+' '+CCu.CurrencyName CountryCurrency,      
		  T.DepositAccountNumber,    
			CASE 
				WHEN EXISTS(SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) THEN NULL
				WHEN CC.IdCountry = @IdCountryUSA THEN NULL
				ELSE Br.Address
			END BranchAddress, --#2
		  case when len(Br.Address) <= 62 then Br.Address --#2
		  else SUBSTRING(Br.Address, 1, 62) END --#2
		  BranchAddressCut, --#2
		  case when len(P.PayerName + ' / ' + Br.BranchName) <= 62 then P.PayerName + ' / ' + Br.BranchName --#2
		  else SUBSTRING(P.PayerName + ' / ' + Br.BranchName, 1, 62) END --#2
		  PayerBranchName,     
		CASE 
			WHEN EXISTS(SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) THEN NULL
			WHEN CC.IdCountry = @IdCountryUSA THEN 'ATM''s Information'
			ELSE Br.BranchName
		END BranchName,
		  Br.Address+' '+ BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode BranchLocation,  
		  BrC.CityName as BranchCity,	--M00077-Modif. de Recibos	
		  BrS.StateName as BranchState,		--M00077-Modif. de Recibos
		  CCo.CountryName as BranchCountry, --M00077-Modif. de Recibos

			CASE 
				WHEN EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) THEN CCo.CountryName
				WHEN CC.IdCountry = @IdCountryUSA  THEN CONCAT(BrS.StateName, ', ', CCo.CountryName)
				WHEN ISNULL(BrS.StateName, '') = '' THEN CCo.CountryName
				ELSE CONCAT(BrC.CityName, ' ', BrS.StateName, ', ', CCo.CountryName)
			END BranchStateAndCountry,
		    --Case SF.State When 'OK' Then 'Oklahoma' When Null Then '' Else  SF.State End StateTax,   
		  Case SF.State 
			When 'OK' Then 'Oklahoma' 
			Else
				case 
					when dbo.fn_getStateTaxFromTransfer(@IdTransfer)>0 and a.agentstate='OK' Then 'Oklahoma' 
					when dbo.fn_getStateTaxFromTransfer(@IdTransfer)>0 and a.agentstate!='OK' Then a.agentstate 
					else 
						''
				end
			End StateTax,    
		  --Isnull(SF.Tax,0) as Tax,  
		  Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdTransfer) ) as Tax,  -- Se agrega funcion para obtener Tax
		  Case When TRS.NewIdTransfer IS NULL  Then @NotResend else @Resend End as IsResend  ,
		  @ComprobanteMessage  ComprobanteMessage,   
		    
		     
 
 --Prueba de Ticket  para California
		         
		 ISNULL(n.[ComplaintNoticeEnglish],'') as ComplaintNoticeEnglish,
		 CASE 
		 WHEN @lenguage2 = 3 THEN ISNULL(n.[ComplaintNoticePortugues],'') 
		 --WHEN @lenguage2 = 3 AND s.StateCode = 'CA' THEN ISNULL(n.[ComplaintNoticePortugues],'') 
		 --WHEN @lenguage2 = 3 AND s.StateCode <> 'CA' AND s.StateCode <> 'CO'THEN n.[ComplaintNoticePortugues] 
		 ELSE ISNULL(n.[ComplaintNoticeSpanish],'') END as ComplaintNoticeSpanish,
		 AffiliationNoticeEnglish = ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),''),
		 AffiliationNoticeSpanish = IIF(CCo.IdCountry IN (@IdCountryVNM, @IdCountryPHL, @IdCountryIDN), '',(case when @lenguage2=3 then
																ISNULL(REPLACE(AffiliationNoticePortugues, '[Agent]', A.AgentName),'')
															else
																ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),'')
															end)), --Ajuste para Recibos de Asia
          ISNULL(br.schedule,'') BranchSchedule,
		     case
            when T.DateOfTransfer<=[dbo].[RemoveTimeFromDatetime](T.DateOfTransfer)+@TimeForClaimTransfer then CONVERT (varchar(10),T.DateOfTransfer,101)
           else CONVERT (varchar(10),T.DateOfTransfer+1,101)
          end
          AvailableDay,
		  case
			when T.IdGateway=4 and T.IdPaymentType in (1,4) and T.IdCountryCurrency=@IdCountryCurrencyMexicoPesos then dbo.RoundBanker( T.AmountInDollars*T.ExRate,2) 
			else T.AmountInMN
		  end CalculatedAmountInMN,		   
		  --@ReceiptTransferConsumerSpanishMessage ReceiptTransferConsumerSpanishMessage,
		  --@ReceiptTransferConsumerEnglishMessage ReceiptTransferConsumerEnglishMessage
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
		  @Disclaimer09EN Disclaimer09EN,
		  @Disclaimer09ES Disclaimer09ES,
		  @Disclaimer10EN Disclaimer10EN,
		  @Disclaimer10ES Disclaimer10ES,
		  @Disclaimer11PO Disclaimer11PO,
		  @Disclaimer12PO Disclaimer12PO,
		  @Disclaimer13PO Disclaimer13PO,

          case isnull(pm.idtransfer,'')
		  when '' then NULL
		  else
		  @BonusMessage end BonusMessage,
		  case 
		  when @IdCountryDestiny = 3
		  then 'By signing here I attest to have received $'+ CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdTransfer) )),2)) + ' from the customer/Reconheço Ter Recebido $'
		  + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdTransfer) )),2)) + ' Do Cliente' --M00077-Modif. de Recibos
		  else
		  'By signing here I attest to have received $'+ CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdTransfer) )),2)) + ' from the customer / Al firmar aquí reconozco haber recibido $'
		  + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdTransfer) )),2)) + ' del cliente' --M00077-Modif. de Recibos
		  end [AttestMessage], 

		  case 
		  when @IdCountryDestiny = 3
		  then 'I attest to have received $'+ CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdTransfer) )),2)) + ' from the customer/Reconheço Ter Recebido $'
		  + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdTransfer) )),2)) + ' Do Cliente'
		  else
		  'I attest to have received $'+ CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdTransfer) )),2)) + ' from the customer/reconozco haber recibido $'
		  + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdTransfer) )),2)) + ' del cliente'
		  end [AttestMessage2], --M00077-Modif. de Recibos

		  /* RESPALDO DE LINEA ORIGINAL SIN VALIDACIÓN PARA BRASIL JFPACO 13092018
		  [AttestMessage] = 'I attest to have received $'+ CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdTransfer) )),2)) + ' from the customer/reconozco haber recibido $'
		  + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,  dbo.fn_getStateTaxFromTransfer(@IdTransfer) )),2)) + ' del cliente'
		  */
		  /*
		  'By signing here I attest to have received $ ' + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,0)),2)) + ' from the customer' + ' / ' +
		  'Al firmar aqui reconozco haber recibido $ ' + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,0)),2)) + ' del cliente' [AttestMessage]*/
		  --,case
		  --when T.IdGateway=4 and T.IdPaymentType in (1,4) and T.IdCountryCurrency=@IdCountryCurrencyMexicoPesos and T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars*T.ExRate,2)  then '*** ' + @DisclaimerEN07 + '.'
		  --else ''
		  --end DisclaimerEn07,
		  @DisclaimerEN07 DisclaimerEn07,
		  --case
		  --when T.IdGateway=4 and T.IdPaymentType in (1,4) and T.IdCountryCurrency=@IdCountryCurrencyMexicoPesos and T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars*T.ExRate,2)  then '*** ' + @DisclaimerEs07 + '.'
		  --else ''
		  --end DisclaimerEs07,
		  @DisclaimerEs07 DisclaimerEs07,
		  CASE WHEN CN.[AllowSentMessages] = 1 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'SendTextMessage') ELSE '' END [SendTextMessageEn],
		  CASE WHEN CN.[AllowSentMessages] = 1 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'SendTextMessage') ELSE '' END [SendTextMessageEs]
		  , '' AccountTypeName, --AT.[AccountTypeName],

/*
		  report.HTML_JUSTIFY(@DisclaimerEn01 + '*** '+ @DisclaimerEn04 + '*** '+ @DisclaimerEn05 + '*** '+ @DisclaimerEn06 
		  + ' Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov*** '+ ISNULL(n.[ComplaintNoticeEnglish],'') +
		  CASE n.[ComplaintNoticeEnglish] WHEN NULL THEN '' ELSE '*** ' END + @ReceiptTransferEnglishMessage + '*** ' + @DisclaimerEN08 + @DisclaimerEN07,
		  61, 'Consolas', 6,0,0) AS EngMess,
		  
		  
		  */
		  
				  
		   (CASE 
			    WHEN 
			     A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN	
					    report.HTML_JUSTIFY(@DisclaimerEn01 + ''+ @DisclaimerEn04 + '*** '+ @DisclaimerEn05 
		          + '|| Recipient may receive less due to fees charged by the recipient’s payer institution and foreign taxes. || '
		          + '|| Recipient may receive less due to fees charged by the recipient’s payer institution and foreign taxes. ||' + @DisclaimerEn06 
		          + ISNULL(n.[ComplaintNoticeEnglish],'') +
						  CASE n.[ComplaintNoticeEnglish] WHEN NULL THEN '' ELSE '*** ' END + @ReceiptTransferEnglishMessage + '*** ' 
						  + ' or Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov ||' 
						  + @DisclaimerEN08 + @DisclaimerEN07,
						  61, 'Consolas', 6,0,0) 
			    

			   else
			     report.HTML_JUSTIFY(@DisclaimerEn01 + '*** '+ @DisclaimerEn04 + '*** '+ @DisclaimerEn05 + '*** '+ @DisclaimerEn06 
				  + ' Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov*** '+ ISNULL(n.[ComplaintNoticeEnglish],'') +
				  CASE n.[ComplaintNoticeEnglish] WHEN NULL THEN '' ELSE '*** ' END + @ReceiptTransferEnglishMessage + '*** ' + @DisclaimerEN08 + @DisclaimerEN07,
				  61, 'Consolas', 6,0,0) 
				 end
				) AS EngMess,
			 
	
	/*
		  report.HTML_JUSTIFY(@DisclaimerES01 + '*** '+ @DisclaimerES04 + '*** '+ @DisclaimerES05 + '*** '+ @DisclaimerES06 
		  + ' Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov*** '+ ISNULL(n.ComplaintNoticeSpanish,'') +
		  CASE n.ComplaintNoticeSpanish WHEN NULL THEN '' ELSE '*** ' END + @ReceiptTransferSpanishMessage + '*** ' + @DisclaimerES08 + @DisclaimerEN07,
		  61, 'Consolas', 6,0,0) AS SpaMess,

*/
    (case
        WHEN 
           A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN	
				  	report.HTML_JUSTIFY(@DisclaimerES01 + @DisclaimerES06 
					    + ISNULL(n.ComplaintNoticeSpanish,'') +
	   					  CASE n.ComplaintNoticeSpanish WHEN NULL THEN '' ELSE '*** ' END + @ReceiptTransferSpanishMessage + '*** ' 
				  	  + ' Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov*** '
						  + @DisclaimerES08 + @DisclaimerEN07,
						  61, 'Consolas', 6,0,0)
				 else
				    report.HTML_JUSTIFY(@DisclaimerES01 + '*** '+ @DisclaimerES04 + '*** '+ @DisclaimerES05 + '*** '+ @DisclaimerES06 
					  + ' Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov*** '+ ISNULL(n.ComplaintNoticeSpanish,'') +
					  CASE n.ComplaintNoticeSpanish WHEN NULL THEN '' ELSE '*** ' END + @ReceiptTransferSpanishMessage + '*** ' + @DisclaimerES08 + @DisclaimerEN07,
					  61, 'Consolas', 6,0,0)
			  end
		  )
		  AS SpaMess,
		  
		  
		  report.HTML_JUSTIFY(CASE WHEN CN.[AllowSentMessages] = 1 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'SendTextMessage') ELSE '' END,
		  61, 'Consolas', 6,0,0) AS [SendTextMessEn],
		  report.HTML_JUSTIFY(CASE WHEN CN.[AllowSentMessages] = 1 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'SendTextMessage') ELSE '' END,
		  61, 'Consolas', 6,0,0) AS [SendTextMessEs],

		   report.HTML_JUSTIFY(ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),'')
		   ,61, 'Consolas', 6,0,0) as AffiliationNoticeEnglishJust,

		   IIF(CCo.IdCountry IN (@IdCountryVNM, @IdCountryPHL, @IdCountryIDN), '',ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),'')) as AffiliationNoticeSpanishJust --Ajuste para Recibos de Asia
		   ,EmphasizedDisclamer = Convert(BIT,CASE WHEN A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN 1 ELSE 0 END) 

		   ,S.StateCode
		   ,@DisclaimerFederalEN as DisclaimerFederalEN
		   ,@DisclaimerFederalES as DisclaimerFederalES
		   ,@Disclaimer13EN as Disclaimer13EN
		   ,@Disclaimer13ES as Disclaimer13ES --M00077-Modif. de Recibos
			,T.IdPaymentType
		   ,CASE 
				WHEN EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) THEN 1
				ELSE 0
		   END OnlyShowCountry,
			@LabelReplaceFolio LabelReplaceFolio,
			@ModificationLabelNewFolio ModificationLabelNewFolio,
			@ModificationLabelNewFolio_Spanish ModificationLabelNewFolioSpanish,
			@IsChangeRequest IsChangeRequest,
			@ShowModificationLabel ShowModificationLabel,
			@PrintedDate as PrintedDate,
			@TimeZone TimeZoneAbbr,
			T.Discount,
			CASE T.IdPaymentMethod
				WHEN 1 THEN [dbo].[GetMessageFromMultiLenguajeResorces](1,'Receipt.MT.PaymentMethod.Cash')
				WHEN 2 THEN [dbo].[GetMessageFromMultiLenguajeResorces](1,'Receipt.MT.PaymentMethod.DebitCard')
			END PaymentMethod,
			(T.AmountInDollars + T.Fee + ISNULL(T.StateTax, 0) - T.Discount) TotalAmountPaid,
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
			) TypeOfService,
			cpm.IdPaymentMethod,
			IIF (CC.IdCountry = @IdCountryUSA,
				[dbo].[fn_GetTyC] (1,1,1),
				CONCAT(
					@DisclaimerEn01, ' ',
					@DisclaimerEn02, ' ',
					@DisclaimerEn03, ' ',
					@DisclaimerEn04, ' ',
					n.ComplaintNoticeEnglish, ' ',
					'Or Consumer Financial Protection Bureau 855-441-2372, 855-729-2372 (TTY/TDD) www.consumerfinance.gov. ',
					@DisclaimerEn05
				)
			) DisclaimerEn,
			IIF (CC.IdCountry = @IdCountryUSA,
				IIF (@AgentStateCa = 'CA',
					[dbo].[fn_GetTyC] (1,0,1),
					@DisclaimerEN06
				),
				@DisclaimerEN06
			) DisclaimerCAEn, 
			IIF(CCo.IdCountry IN (@IdCountryVNM, @IdCountryPHL, @IdCountryIDN),
				'',
				IIF (CC.IdCountry = @IdCountryUSA,
					[dbo].[fn_GetTyC] (1,1,2),
					CONCAT(
						@DisclaimerEs01, ' ',
						@DisclaimerEs02, ' ',
						@DisclaimerEs03, ' ',
						@DisclaimerEs04, ' ',
						n.ComplaintNoticeSpanish, ' ',
						'o Consumer Financial Protection Bureau al 855-441-2372, 855-729-2372 (TTY / TDD) www.consumerfinance.gov. ',
						@DisclaimerEs05
					)
				)
			) DisclaimerES,
			IIF(CCo.IdCountry IN (@IdCountryVNM, @IdCountryPHL, @IdCountryIDN),
				'',
				IIF (CC.IdCountry = @IdCountryUSA,
					IIF (@AgentStateCa = 'CA',
						[dbo].[fn_GetTyC] (1,0,2),
						@DisclaimerES06
					),
					@DisclaimerES06
				)
			) DisclaimerCAEs,
			A.IdAgent
		from Transfer T WITH (NOLOCK)
		 inner join Agent A WITH (NOLOCK) on A.IdAgent=T.IdAgent      
		 inner join Users U WITH (NOLOCK) on U.IdUser = T.EnterByIdUser      
		 inner join Beneficiary B WITH (NOLOCK) on B.IdBeneficiary =T.IdBeneficiary
		 inner join Payer P WITH (NOLOCK) on P.IdPayer = T.IdPayer      
		 inner join PaymentType Py WITH (NOLOCK) on Py.IdPaymentType =T.IdPaymentType      
		 inner join CountryCurrency CC WITH (NOLOCK) on CC.IdCountryCurrency =T.IdCountryCurrency      
		 inner join Currency CCu WITH (NOLOCK) on CCu.IdCurrency =CC.IdCurrency      
		 inner join Country CCo WITH (NOLOCK) on CCo.IdCountry =CC.IdCountry      
		 left join Branch Br WITH (NOLOCK) on Br.IdBranch = T.IdBranch   
		 left join City BrC WITH (NOLOCK) on BrC.IdCity = Br.IdCity      
		 left join State BrS WITH (NOLOCK) on BrS.IdState = BrC.IdState   
		left join Country BrCt WITH (NOLOCK) on BrCt.IdCountry = BrS.IdCountry
		 left join GatewayBranch GB WITH (NOLOCK) on GB.IdBranch =T.IdBranch and GB.IdGateway = T.IdGateway      
		 left join TransferResend TR WITH (NOLOCK) on TR.IdTransfer = T.IdTransfer      
		 left join Transfer TTR WITH (NOLOCK) on TTR.IdTransfer = TR.IdTransfer    
		 left join StateFee SF WITH (NOLOCK) on SF.IdTransfer=T.IdTransfer  
		 left join TransferResend TRS WITH (NOLOCK) on TRS.IdTransfer=T.IdTransfer      
		 --LEFT JOIN dbo.[State] s ON  s.StateCode = isnull(nullif(T.CustomerState,''),A.AgentState) and s.idcountry=18
		 LEFT JOIN dbo.[State] s WITH (NOLOCK) ON s.StateCode = isnull(A.AgentState,'') and s.idcountry=18--#1
		 LEFT JOIN StateNote n WITH (NOLOCK) ON s.IdState = n.idstate 
         left join PureMinutesTransaction pm WITH (NOLOCK) on t.idtransfer=pm.idtransfer and status=1

		 --LEFT JOIN [Infinite].[CellularNumber] CN ON T.[CustomerCelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = @InterCode -- - #MP-1268
		 LEFT JOIN DialingCodePhoneNumber dc WITH (NOLOCK) ON dc.IdDialingCodePhoneNumber = t.IdDialingCodePhoneNumber -- + #MP-1268
		 LEFT JOIN [Infinite].[CellularNumber] CN WITH (NOLOCK) ON T.[CustomerCelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = ISNULL(dc.Prefix, @InterCode) -- + #MP-1268

		 LEFT JOIN [dbo].[AccountType] AT WITH (NOLOCK) ON T.[AccountTypeId] = AT.[AccountTypeId]
		 LEFT JOIN TransferModify TM WITH(NOLOCK) ON TM.NewIdTransfer = T.IdTransfer /*M00056*/
		 JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)
		 where T.IdTransfer = @IdTransfer
 
 End
 Else
 Begin

 --- Conversion Hora Local TransferClosed

Declare @receiptType1 bit = 0

	   Select DateOfTransferLocal,
			  PrintedDate,
			  TimeZone

		into #LocalTimeTC                       
			 from [dbo].[FnConvertLocalTimeZone] (@IdTransfer,@receiptType1) -- Se invoca Funcion Timezone
		
	Declare @LocalDate1 datetime,
			@PrintedDate1 datetime,
			@TimeZone1 nvarchar(3)

	 select @LocalDate1=DateOfTransferLocal,
	        @TimeZone1=TimeZone,
			@PrintedDate1=PrintedDate
	 from #LocalTimeTC
		
		Drop table #LocalTimeTC
				

--- Termina Conversion


		 set @ComprobanteMessage= (select top 1 1 from BrokenRulesByTransfer WITH (NOLOCK) where IdTransfer=@IdTransfer and IdKYCAction=4 and MessageInSpanish like '%comprobante de ingresos%' )
		 Select       
		  @CorporationPhone CorporationPhone,      
		  @CorporationName CorporationName,    
		  @ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		  @ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,  
		  ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,     
		  A.AgentAddress AgentAddress,
		  A.AgentCity+ ' '+ A.AgentState + ' '+ 
			REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS AgentLocation,
		  A.AgentPhone,      
		  T.Folio,
		  (SELECT TOP 1 CAST(Folio AS VARCHAR) FROM Transfer WITH(NOLOCK) WHERE IdTransfer = TM.OldIdTransfer) FolioTM,       
		  U.UserLogin,      
		  @LocalDate1 as DateOfTransfer,        
		  T.ClaimCode,      
		  T.IdCustomer,      
		  T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName,      
			CONCAT(
				T.CustomerAddress, ', ', 
				T.CustomerCity, ' ', 
				T.CustomerState, ' ', 
				REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0')
			) CustomerAddress,         
		  T.CustomerCity+' '+ T.CustomerState+' '+
			REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') AS  CustomerLocation,      
		  T.CustomerPhoneNumber,  
  		  T.CustomerCelullarNumber,
		  CASE WHEN CN.[AllowSentMessages] = 1 THEN 'YES' ELSE 'NO' END [CustomerReceiveMessage],
		  T.BeneficiaryName+' '+T.BeneficiaryFirstLastName+' '+ T.BeneficiarySecondLastName BeneficiaryFullName,      
			LTRIM(
				IIF((EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = T.IdPaymentType) AND ISNULL(T.BeneficiaryAddress, '') = ''), --SI ES IdPaymentType = DEPOSITO MOSTRAR SOLO PAIS BM-1040
					CASE 
						WHEN ISNULL(T.BeneficiaryCountry, '') <> '' THEN T.BeneficiaryCountry
						WHEN BrCt.IdCountry IS NOT NULL THEN BrCt.CountryName
						ELSE CCo.CountryName
					END,
					CONCAT(
						IIF(ISNULL(T.BeneficiaryAddress, '') <> '', CONCAT(T.BeneficiaryAddress, ', ', T.BeneficiaryCity), ''),
						' ',
						CASE 
							WHEN ISNULL(T.BeneficiaryState, '') <> '' THEN CONCAT( T.BeneficiaryState, ', ')
							WHEN ISNULL(BrS.StateName, '') <> '' THEN CONCAT(BrS.StateName, ', ')
							ELSE NULL
						END,
						CASE 
							WHEN ISNULL(T.BeneficiaryCountry, '') <> '' THEN T.BeneficiaryCountry
							WHEN BrCt.IdCountry IS NOT NULL THEN BrCt.CountryName
							ELSE CCo.CountryName
						END
					)
				)
			) BeneficiaryAddress,   
		  case       
			WHEN EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) AND T.BeneficiaryCity='' THEN BrCt.CountryName
			when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode   
			else B.City+' '+B.State+' '+B.Zipcode    
		  end BeneficiaryLocation,
		  CASE
			WHEN EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) AND T.BeneficiaryCity='' THEN BrCt.CountryName
			WHEN T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName      
			ELSE B.City+' '+B.State   
		  END BeneficiaryOnlyCityState, --M00077-Modif. de Recibos
		  --B.City+' '+B.State BeneficiaryOnlyCityState, 		--M00077-Modif. de Recibos
	      Cco.CountryName CountryName,      
		  T.BeneficiaryCelularNumber AS BeneficiaryPhoneNumber,  
		  T.BeneficiaryCelularNumber,   
		  T.BeneficiaryCountry,
		  --Prueba Beneficiary Mirror
		  @BeneficiaryMirrorFullName BeneficiaryMirrorFullName,
		  @BeneficiaryMirrorAddress BeneficiaryMirrorAddress,
		  @BeneficiaryMirrorLocation BeneficiaryMirrorLocation, 
		  @BeneficiaryMirrorPhoneNumber BeneficiaryMirrorPhoneNumber,
		  @BeneficiaryMirrorCellPhoneNumber BeneficiaryMirrorCellPhoneNumber, 
		  @BeneficiaryMirrorCountry BeneficiaryMirrorCountry,
		  --Termina prueba Beneficiary Mirror    
		  Py.PaymentName,      
		  T.AmountInDollars,      
		  T.Fee - T.Discount Fee,     

		--T.ExRate,  
		  ROUND(T.ExRate,2) AS ExRate, /*ticket 1523:Mantis 0001537*/

		  P.PayerName,      
		  GB.GatewayBranchCode,      
		  CASE 
			WHEN CCu.CurrencyCode = 'MXP' THEN 'MXN' 
			--WHEN CC.IdCountry = @IdCountryUSA THEN 'US'
			ELSE CCu.CurrencyCode 
		  END AS CurrencyCode,
		  T.AmountInMN,   
		  0.0 OtherFeeMN,
		  CCo.CountryName+' '+CCu.CurrencyName CountryCurrency,      
		  T.DepositAccountNumber,   
			CASE 
				WHEN EXISTS(SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) THEN NULL
				WHEN CC.IdCountry = @IdCountryUSA THEN NULL
				ELSE Br.Address
			END BranchAddress, --#2
		  case when len(Br.Address) <= 62 then Br.Address
		  else SUBSTRING(Br.Address, 1, 62) END
		  BranchAddressCut,
		CASE 
			WHEN EXISTS(SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) THEN NULL
			WHEN CC.IdCountry = @IdCountryUSA THEN 'ATM''s Information'
			ELSE Br.BranchName
		END BranchName,  
		  case when len(P.PayerName + ' / ' + Br.BranchName) <= 62 then P.PayerName + ' / ' + Br.BranchName
		  else SUBSTRING(P.PayerName + ' / ' + Br.BranchName, 1, 62) END
		  PayerBranchName,
		  Br.Address+' '+ BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode BranchLocation,  
		  BrC.CityName as BranchCity,		 --M00077-Modif. de Recibos
		  BrS.StateName as BranchState,		
		  CCo.CountryName as BranchCountry,   --M00077-Modif. de Recibos
			CASE 
				WHEN EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) THEN CCo.CountryName
				WHEN CC.IdCountry = @IdCountryUSA  THEN CONCAT(BrS.StateName, ', ', CCo.CountryName)
				WHEN ISNULL(BrS.StateName, '') = '' THEN CCo.CountryName
				ELSE CONCAT(BrC.CityName, ' ', BrS.StateName, ', ', CCo.CountryName)
			END BranchStateAndCountry,
		  Case SF.State When 'OK' Then 'Oklahoma' When Null Then '' Else  SF.State End StateTax,    
		  Isnull(SF.Tax,0) as Tax,  
		  Case When TRS.NewIdTransfer IS NULL  Then @NotResend else @Resend End as IsResend,
		  @ComprobanteMessage  ComprobanteMessage,
		  ISNULL(n.[ComplaintNoticeEnglish],'') as ComplaintNoticeEnglish,
		  ISNULL(n.[ComplaintNoticeSpanish],'') as ComplaintNoticeSpanish,
		  ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),'') as AffiliationNoticeEnglish,
		  IIF(CCo.IdCountry IN (@IdCountryVNM, @IdCountryPHL, @IdCountryIDN), '',ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),'')) as AffiliationNoticeSpanish, --Ajuste para Recibos de Asia
          ISNULL(br.schedule,'') BranchSchedule,
		     case
            when T.DateOfTransfer<=[dbo].[RemoveTimeFromDatetime](T.DateOfTransfer)+@TimeForClaimTransfer then CONVERT (varchar(10),T.DateOfTransfer,101)
           else CONVERT (varchar(10),T.DateOfTransfer+1,101)
          end
          AvailableDay,
     /*case
            when T.DateOfTransfer<=[dbo].[RemoveTimeFromDatetime](T.DateOfTransfer)+@TimeForClaimTransfer then CONVERT (varchar(10),T.DateOfTransfer,101)
            when T.DateOfTransfer>[dbo].[RemoveTimeFromDatetime](T.DateOfTransfer) and @DayOfWeek=6 then CONVERT (varchar(10),T.DateOfTransfer+2,101)
            when @DayOfWeek=7 then CONVERT (varchar(10),T.DateOfTransfer+1,101)
            else CONVERT (varchar(10),T.DateOfTransfer+1,101)
          end
          AvailableDay,*/
		  case
			when T.IdGateway=4 and T.IdPaymentType in (1,4) and T.IdCountryCurrency=@IdCountryCurrencyMexicoPesos then dbo.RoundBanker( T.AmountInDollars*T.ExRate,2) 
			else T.AmountInMN
		  end CalculatedAmountInMN,		
		  --@ReceiptTransferConsumerSpanishMessage ReceiptTransferConsumerSpanishMessage,
		  --@ReceiptTransferConsumerEnglishMessage ReceiptTransferConsumerEnglishMessage
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

          case isnull(pm.idtransfer,'')
            when '' then null
            else
            @BonusMessage end
          BonusMessage,

		  'By signing here I attest to have received $ ' + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,0)),2)) + ' from the customer' + ' / ' +
		  'Al firmar aquí reconozco haber recibido $ ' + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,0)),2)) + ' del cliente' [AttestMessage], --M00077-Modif. de Recibos

		  'I attest to have received $ ' + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,0)),2)) + ' from the customer' + '/' +
		  'reconozco haber recibido $ ' + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,0)),2)) + ' del cliente' [AttestMessage2] --M00077-Modif. de Recibos

		  ,case
		  when T.IdGateway=4 and T.IdPaymentType in (1,4) and T.IdCountryCurrency=@IdCountryCurrencyMexicoPesos and T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars*T.ExRate,2) then '*** ' + @DisclaimerEN07 + '.'
		  else ''
		  end DisclaimerEn07,
		  case
		  when T.IdGateway=4 and T.IdPaymentType in (1,4) and T.IdCountryCurrency=@IdCountryCurrencyMexicoPesos and T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars*T.ExRate,2) then '*** ' + @DisclaimerEs07 + '.'
		  else ''
		  end DisclaimerEs07,
		  CASE WHEN CN.[AllowSentMessages] = 1 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'SendTextMessage') ELSE '' END [SendTextMessageEn],
		  CASE WHEN CN.[AllowSentMessages] = 1 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'SendTextMessage') ELSE '' END [SendTextMessageEs]
		  , '' AccountTypeName, --AT.[AccountTypeName],

     /*
		    report.HTML_JUSTIFY(@DisclaimerEn01 + '*** '+ @DisclaimerEn04 + '*** '+ @DisclaimerEn05 + '*** '+ @DisclaimerEn06 
		  + ' Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov*** '+ ISNULL(n.[ComplaintNoticeEnglish],'') +
		  CASE n.[ComplaintNoticeEnglish] WHEN NULL THEN '' ELSE '*** ' END + @ReceiptTransferEnglishMessage + '*** ' + @DisclaimerEN08 + @DisclaimerEN07,
		  61, 'Consolas', 6,0,0) AS EngMess,
		  
		  
		  */
				   (CASE 
			    WHEN 
			     A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN	
					    report.HTML_JUSTIFY(@DisclaimerEn01 + ''+ @DisclaimerEn04 + '*** '+ @DisclaimerEn05 
		          + '|| Recipient may receive less due to fees charged by the recipient’s payer institution and foreign taxes. || '
		          + '|| Recipient may receive less due to fees charged by the recipient’s payer institution and foreign taxes. ||' + @DisclaimerEn06 
		          + ISNULL(n.[ComplaintNoticeEnglish],'') +
						  CASE n.[ComplaintNoticeEnglish] WHEN NULL THEN '' ELSE '*** ' END + @ReceiptTransferEnglishMessage + '*** ' 
						  + ' or Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov ||' 
						  + @DisclaimerEN08 + @DisclaimerEN07,
						  61, 'Consolas', 6,0,0) 
			    

			   else
			     report.HTML_JUSTIFY(@DisclaimerEn01 + '*** '+ @DisclaimerEn04 + '*** '+ @DisclaimerEn05 + '*** '+ @DisclaimerEn06 
				  + ' Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov*** '+ ISNULL(n.[ComplaintNoticeEnglish],'') +
				  CASE n.[ComplaintNoticeEnglish] WHEN NULL THEN '' ELSE '*** ' END + @ReceiptTransferEnglishMessage + '*** ' + @DisclaimerEN08 + @DisclaimerEN07,
				  61, 'Consolas', 6,0,0) 
				 end
				) AS EngMess,
		  (case
		        WHEN 
		           A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN	
						  	report.HTML_JUSTIFY(@DisclaimerES01 + @DisclaimerES06 
							    + ISNULL(n.ComplaintNoticeSpanish,'') +
			   					  CASE n.ComplaintNoticeSpanish WHEN NULL THEN '' ELSE '*** ' END + @ReceiptTransferSpanishMessage + '*** ' 
						  	  + ' Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov*** '
								  + @DisclaimerES08 + @DisclaimerEN07,
								  61, 'Consolas', 6,0,0)
						 else
						    report.HTML_JUSTIFY(@DisclaimerES01 + '*** '+ @DisclaimerES04 + '*** '+ @DisclaimerES05 + '*** '+ @DisclaimerES06 
							  + ' Consumer Financial Protection Bureau 855-441-2372 855-729-2372 (TTY/TDD) www.consumerfinance.gov*** '+ ISNULL(n.ComplaintNoticeSpanish,'') +
							  CASE n.ComplaintNoticeSpanish WHEN NULL THEN '' ELSE '*** ' END + @ReceiptTransferSpanishMessage + '*** ' + @DisclaimerES08 + @DisclaimerEN07,
							  61, 'Consolas', 6,0,0)
					  end
				  )
				  AS SpaMess,

		  report.HTML_JUSTIFY(CASE WHEN CN.[AllowSentMessages] = 1 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'SendTextMessage') ELSE '' END,
		  61, 'Consolas', 6,0,0) AS [SendTextMessEn],
		  report.HTML_JUSTIFY(CASE WHEN CN.[AllowSentMessages] = 1 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'SendTextMessage') ELSE '' END,
		  61, 'Consolas', 6,0,0) AS [SendTextMessEs],
		     report.HTML_JUSTIFY(ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),'')
		   ,61, 'Consolas', 6,0,0) as AffiliationNoticeEnglishJust,
		  IIF(CCo.IdCountry IN (@IdCountryVNM, @IdCountryPHL, @IdCountryIDN), '',report.HTML_JUSTIFY(ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),''),61, 'Consolas', 6,0,0)) as AffiliationNoticeSpanishJust
		   ,EmphasizedDisclamer = Convert(BIT,CASE WHEN A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN 1 ELSE 0 END)
		   ,S.StateCode
		   ,@DisclaimerFederalEN as DisclaimerFederalEN
		   ,@DisclaimerFederalES as DisclaimerFederalES
		   ,@Disclaimer13EN as Disclaimer13EN
		   ,@Disclaimer13ES as Disclaimer13ES --M00077-Modif. de Recibos
		   ,T.IdPaymentType
		   ,CASE 
				WHEN EXISTS (SELECT 1 FROM @HideCityAndStatePaymentType h WHERE h.Id = t.IdPaymentType) THEN 1
				ELSE 0
		   END OnlyShowCountry,
		   	@LabelReplaceFolio LabelReplaceFolio,
			@ModificationLabelNewFolio ModificationLabelNewFolio,
			@ModificationLabelNewFolio_Spanish ModificationLabelNewFolioSpanish,
			@IsChangeRequest IsChangeRequest,
			@ShowModificationLabel ShowModificationLabel,
			@PrintedDate1 as PrintedDate,
			@TimeZone1 as TimeZoneAbbr,
			T.Discount,
			CASE T.IdPaymentMethod
				WHEN 1 THEN [dbo].[GetMessageFromMultiLenguajeResorces](1,'Receipt.MT.PaymentMethod.Cash')
				WHEN 2 THEN [dbo].[GetMessageFromMultiLenguajeResorces](1,'Receipt.MT.PaymentMethod.DebitCard')
			END PaymentMethod,
			(T.AmountInDollars + T.Fee + ISNULL(SF.Tax, 0) - T.Discount) TotalAmountPaid,
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
			) TypeOfService,
			cpm.IdPaymentMethod,
			IIF (CC.IdCountry = @IdCountryUSA,
				[dbo].[fn_GetTyC] (1,1,1),
				CONCAT(
					@DisclaimerEn01, ' ',
					@DisclaimerEn02, ' ',
					@DisclaimerEn03, ' ',
					@DisclaimerEn04, ' ',
					n.ComplaintNoticeEnglish, ' ',
					'Or Consumer Financial Protection Bureau 855-441-2372, 855-729-2372 (TTY/TDD) www.consumerfinance.gov. ',
					@DisclaimerEn05
				)
			) DisclaimerEn,
			IIF (CC.IdCountry = @IdCountryUSA,
				IIF (@AgentStateCa = 'CA',
					[dbo].[fn_GetTyC] (1,0,1),
					@DisclaimerEN06
				),
				@DisclaimerEN06
			) DisclaimerCAEn, 
			IIF(CCo.IdCountry IN (@IdCountryVNM, @IdCountryPHL, @IdCountryIDN),
				'',
				IIF (CC.IdCountry = @IdCountryUSA,
					[dbo].[fn_GetTyC] (1,1,2),
					CONCAT(
						@DisclaimerEs01, ' ',
						@DisclaimerEs02, ' ',
						@DisclaimerEs03, ' ',
						@DisclaimerEs04, ' ',
						n.ComplaintNoticeSpanish, ' ',
						'o Consumer Financial Protection Bureau al 855-441-2372, 855-729-2372 (TTY / TDD) www.consumerfinance.gov. ',
						@DisclaimerEs05
					)
				)
			) DisclaimerES,
			IIF(CCo.IdCountry IN (@IdCountryVNM, @IdCountryPHL, @IdCountryIDN),
				'',
				IIF (CC.IdCountry = @IdCountryUSA,
					IIF (@AgentStateCa = 'CA',
						[dbo].[fn_GetTyC] (1,0,2),
						@DisclaimerES06
					),
					@DisclaimerES06
				)
			) DisclaimerCAEs,
			IIF(CCo.IdCountry IN (@IdCountryVNM, @IdCountryPHL, @IdCountryIDN), '', @DisclaimerES06) DisclaimerCAEs,
			A.IdAgent
		from TransferClosed T WITH (NOLOCK)
		 inner join Agent A WITH (NOLOCK) on A.IdAgent=T.IdAgent      
		 inner join Users U WITH (NOLOCK) on U.IdUser = T.EnterByIdUser      
		 inner join Beneficiary B WITH (NOLOCK) on B.IdBeneficiary =T.IdBeneficiary      
		 inner join Payer P WITH (NOLOCK) on P.IdPayer = T.IdPayer      
		 inner join PaymentType Py WITH (NOLOCK) on Py.IdPaymentType =T.IdPaymentType      
		 inner join CountryCurrency CC WITH (NOLOCK) on CC.IdCountryCurrency =T.IdCountryCurrency      
		 inner join Currency CCu WITH (NOLOCK) on CCu.IdCurrency =CC.IdCurrency      
		 inner join Country CCo WITH (NOLOCK) on CCo.IdCountry =CC.IdCountry      
		 left join Branch Br WITH (NOLOCK) on Br.IdBranch = T.IdBranch      
		 left join City BrC WITH (NOLOCK)on BrC.IdCity = Br.IdCity      
		 left join [State] BrS WITH (NOLOCK) on BrS.IdState = BrC.IdState      
		 left join Country BrCt WITH (NOLOCK) on BrCt.IdCountry = BrS.IdCountry
		 left join GatewayBranch GB WITH (NOLOCK) on GB.IdBranch =T.IdBranch and GB.IdGateway = T.IdGateway      
		 left join TransferResend TR WITH (NOLOCK) on TR.IdTransfer = T.IdTransferClosed      
		 left join [Transfer] TTR WITH (NOLOCK) on TTR.IdTransfer = TR.IdTransfer    
		 left join StateFee SF WITH (NOLOCK) on SF.IdTransfer=T.IdTransferClosed  
		 left join TransferResend TRS WITH (NOLOCK) on TRS.IdTransfer=T.IdTransferClosed      
		 --LEFT JOIN dbo.[State] s ON  s.StateCode = isnull(nullif(T.CustomerState,''),A.AgentState) and s.idcountry=18
		 LEFT JOIN dbo.[State] s WITH (NOLOCK) ON s.StateCode = isnull(A.AgentState,'') and s.idcountry=18--#1
		 LEFT JOIN StateNote n WITH (NOLOCK) ON s.IdState = n.idstate  
         left join PureMinutesTransaction pm WITH (NOLOCK) on t.IdTransferClosed=pm.idtransfer and [status]=1

		 -- LEFT JOIN [Infinite].[CellularNumber] CN ON T.[CustomerCelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = @InterCode -- - #MP-1268
		 LEFT JOIN DialingCodePhoneNumber dc WITH (NOLOCK) ON dc.IdDialingCodePhoneNumber = t.IdDialingCodePhoneNumber -- + #MP-1268
		 LEFT JOIN [Infinite].[CellularNumber] CN WITH (NOLOCK) ON T.[CustomerCelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = ISNULL(dc.Prefix, @InterCode) -- + #MP-1268

		 LEFT JOIN [dbo].[AccountType] AT WITH (NOLOCK) ON T.[AccountTypeId] = AT.[AccountTypeId]
		 LEFT JOIN TransferModify TM WITH(NOLOCK) ON TM.NewIdTransfer = T.IdTransferClosed /*M00056*/
		 JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)
		 where T.IdTransferClosed = @IdTransfer     

 
 
		 End

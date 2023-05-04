
/********************************************************************
<Author>  </Author>
<app>Agent, Corporative</app>
<Description> Se agrega validación para lenguaje portugues </Description>

<ChangeLog>
<log Date="14/09/2018" Author="jresendiz">Creacion</log>
</ChangeLog>
*********************************************************************/
--   [MaxiMobile].[GetTransactionReceipt]9991035,18,11
create procedure [MaxiMobile].[GetTransactionReceipt_BKP20200208]--9984553,18,11
(	@IdTransfer int,
	@IdCountryOrigin int,
	@IdCountryDestiny int
) AS

/********************************************************************
--exec [st_GetTransactionReceipt] 9984553,18,3 --CO
exec [st_GetTransactionReceipt] 9984555,18,3 --TX
exec [st_GetTransactionReceipt] 9984559,18,3 --CA
<ChangeLog>
<log Date="19/05/2017" Author="sgarcia">se tomó como base el sp st_GetTransactionReceipt de sistema POS para hacer los cambios descritos en el CR M0015 Homologación de recibos</log>
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

select @lenguage1=idlenguage from countrylenguage where idcountry=@IdCountryOrigin
if @lenguage1 is null
begin    
    select @lenguage1=idlenguage from countrylenguage where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryUSA'))
end

select @lenguage2=idlenguage from countrylenguage where idcountry=@IdCountryDestiny
if @lenguage2 is null
begin    
    select @lenguage2=idlenguage from countrylenguage where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryMexico'))
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




-----mensajes
 
   
select @ReceiptTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferMessage'),   
       @ReceiptTransferSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ReceiptTransferMessage'),
       @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer10'), --M00077-Modif. de Recibos()
       @DisclaimerEN02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer4'),
       @DisclaimerEN03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer5'),
       @DisclaimerEN04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer6'),
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


declare  @AgentStateCa varchar(10)

set @AgentStateCa = (SELECT A.AgentState FROM [Transfer] T INNER JOIN Agent A ON T.IdAgent = A.IdAgent WHERE T.IdTransfer= @IdTransfer) 

if (@AgentStateCa='' OR @AgentStateCa is null)
begin
	set @AgentStateCa = (SELECT A.AgentState FROM [TransferClosed] T with(nolock) INNER JOIN Agent A with(nolock) ON T.IdAgent = A.IdAgent WHERE T.IdTransferClosed= @IdTransfer) 
end

IF(@AgentStateCa = 'CA') --M00077-Modif. de Recibos
BEGIN
	SELECT @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer10CA')
	SELECT @DisclaimerEN05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer9CA')
	SELECT @DisclaimerES05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer9CA')
END					 
--if exists (select 1 from  @BoldDisclamerStates where AgentState = @AgentStateCa)
--begin
--	set @isAgentCA=1
--	set @ReceiptTransferEnglishMessage =''
--	set @ReceiptTransferSpanishMessage =''
--	select 	@DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1Ca')
--	select	@DisclaimerES01= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10Ca') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer1Ca') END		
--	select	@DisclaimerES08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8CA')
--	select  @DisclaimerEN08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer8CA')
--	select	@DisclaimerES04= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer11Ca') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer4') END		
--	select	@DisclaimerES05= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer12Ca') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer5') END		
--	select	@DisclaimerES06= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer13Ca') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer6') END		
--	select	@DisclaimerES08= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8CA') END
--	select	@Disclaimer13EN=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer13ENCa')
--	select	@Disclaimer13ES= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer13PORCa') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer13ESCa') END
--end 
--ELSE
--BEGIN
	--IF (@AgentStateCa = 'CO')
	--BEGIN
	--	SELECT @DisclaimerEN01= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1Co') 
	--	SELECT @DisclaimerEN08= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer8Ca') 
	--	SELECT @DisclaimerES04= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer11') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer4') END		
	--	SELECT @DisclaimerES05= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer12') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer5') END		
	--	SELECT @DisclaimerES06= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer6') END		
	--	SELECT @DisclaimerES08= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8') END		
	--	SELECT @DisclaimerES02= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer9') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer2') END		
	--	--SELECT @DisclaimerES03= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer3') END
	--END
	--ELSE
	--BEGIN
--		SELECT @DisclaimerEN01= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1Co') 
--		SELECT @DisclaimerES04= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer11') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer4') END		
--		SELECT @DisclaimerES05= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer7') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer5') END		
--		SELECT @DisclaimerES06= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer6') END		
--		SELECT @DisclaimerES02= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer9') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer2') END		
--		SELECT @DisclaimerES03= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer3') END		
--		SELECT @DisclaimerES08= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8') END
--	END
--END  
--M00077-Modif. de Recibos
SELECT @DisclaimerFederalEN=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerFederalEN')
SELECT @DisclaimerFederalES= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalPOR') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalES') END

--IF @lenguage2 = 3  
--	BEGIN
--	SELECT @DisclaimerFederalEN=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerFederalEN')
--	SELECT @DisclaimerFederalES= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalPOR') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalES') END
--		IF (@AgentStateCa = 'CA')
--			SELECT @DisclaimerEN06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer6Portugues')
--		IF (@AgentStateCa = 'CO')
--			SELECT @DisclaimerEN06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer6PortuguesCo')
--		ELSE
--			SELECT @DisclaimerEN06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer6')
--	END
--ELSE
--	BEGIN
--		SELECT @DisclaimerEN06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer6')
--	END
 --M00077-Modif. de Recibos
 
--BeneficiaryMirror
declare @TopBeneficiaryMirrorid int
declare @BeneficiaryMirrorFullName nvarchar(max)
declare @BeneficiaryMirrorAddress nvarchar(max)
declare @BeneficiaryMirrorLocation nvarchar(max)
declare @BeneficiaryMirrorPhoneNumber nvarchar(max)
declare @BeneficiaryMirrorCellPhoneNumber nvarchar(max)
declare @BeneficiaryMirrorCountry nvarchar(max)

IF exists(Select 1 from BeneficiaryMirror where IdTransfer = @IdTransfer)
	BEGIN
		select @TopBeneficiaryMirrorid = max(IdBeneficiaryMirror) from BeneficiaryMirror where IdTransfer = @IdTransfer; 

		select top 1 @BeneficiaryMirrorFullName = Name + ' ' + FirstLastName + ' ' + SecondLastName, 
					 @BeneficiaryMirrorAddress = Address,
					 @BeneficiaryMirrorLocation = City + ' ' + State + ' ' + Zipcode,
					 @BeneficiaryMirrorPhoneNumber = PhoneNumber, 
					 @BeneficiaryMirrorCellPhoneNumber = CelullarNumber,
					 @BeneficiaryMirrorCountry = Country 
					 from BeneficiaryMirror 
					 where IdTransfer = @IdTransfer
					 and IdBeneficiaryMirror = @TopBeneficiaryMirrorid; 
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

IF exists(Select 1 from TransferModify where NewIdTransfer = @IdTransfer) 
	BEGIN
		select @IdTransferModify = OldIdTransfer from TransferModify where NewIdTransfer = @IdTransfer
		select @TopBeneficiaryMirrorid = max(IdBeneficiaryMirror) from BeneficiaryMirror where IdTransfer = @IdTransferModify; 

		select top 1 @BeneficiaryMirrorFullName = Name + ' ' + FirstLastName + ' ' + SecondLastName, 
					 @BeneficiaryMirrorAddress = Address,
					 @BeneficiaryMirrorLocation = City + ' ' + State + ' ' + Zipcode,
					 @BeneficiaryMirrorPhoneNumber = PhoneNumber, 
					 @BeneficiaryMirrorCellPhoneNumber = CelullarNumber,
					 @BeneficiaryMirrorCountry = Country 
					 from BeneficiaryMirror 
					 where IdTransfer = @IdTransferModify
					 and IdBeneficiaryMirror = @TopBeneficiaryMirrorid; 
	END


IF(@BeneficiaryMirrorCellPhoneNumber = NULL) 
BEGIN
SET @BeneficiaryMirrorCellPhoneNumber=@BeneficiaryMirrorPhoneNumber
END
ELSE
BEGIN
SET @BeneficiaryMirrorPhoneNumber=@BeneficiaryMirrorCellPhoneNumber
END
 
declare @logo varchar(max) 
declare @idAgent int
declare @fileGuid varchar(max)

If exists(Select 1 from [Transfer] with(nolock) where IdTransfer=@IdTransfer)
begin
select top 1 @idAgent = t.IdAgent,@fileGuid = cast(u.FileGuid as varchar(max))+u.Extension
		from [Transfer] t  with(nolock)
		inner join UploadFiles u  with(nolock) on t.IdAgent = u.IdReference
		inner join Agent a with(nolock) on t.IdAgent = a.IdAgent
		where t.IdTransfer = @IdTransfer
		and u.IdDocumentType = 58
		and u.IdStatus = 1
		and a.ShowLogo = 1 
		order by u.IdUploadFile desc
end
else
	begin
		select top 1 t.IdAgent,u.FileGuid, u.Extension
		from TransferClosed t   with(nolock)
		inner join UploadFiles u  with(nolock) on t.IdAgent = u.IdReference
		inner join Agent a with(nolock) on t.IdAgent = a.IdAgent
		where t.IdTransferClosed = @idTransfer
		and u.IdDocumentType = 58
		and u.IdStatus = 1
		and a.ShowLogo = 1 
		order by u.IdUploadFile desc
	end


set @logo = (Select Value from GlobalAttributes where name = 'FileSystemUploadFiles') 

set @logo = @logo + '\Agents\' + cast(@idAgent as varchar(max)) + '\' + @fileGuid


--select @logo
If exists(Select 1 from Transfer where IdTransfer=@IdTransfer)    
Begin
		set @ComprobanteMessage= (select top 1 1 from BrokenRulesByTransfer where IdTransfer=@IdTransfer and IdKYCAction=4 and MessageInSpanish like '%comprobante de ingresos%' )

		Select       
		  @CorporationPhone CorporationPhone,      
		  @CorporationName CorporationName,    
		  @ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		  @ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,  
		  A.AgentCode+' '+ A.AgentName AgentName,      
		  A.AgentAddress,      
		  A.AgentCity+ ' '+ A.AgentState + ' '+ 
			REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS AgentLocation,
		  A.AgentPhone,      
		  T.Folio,
		  (Select Top 1 Coalesce('Folio: ' + Cast(Folio as varchar(10)),'0') from Transfer with(nolock) where IdTransfer = TM.OldIdTransfer)  FolioTM,         
		  U.UserLogin,      
		  T.DateOfTransfer,        
		  T.ClaimCode,      
		  T.IdCustomer,      
		  T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName,      
		  T.CustomerAddress,      
		  T.CustomerCity+' '+ T.CustomerState+' '+
			REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') AS  CustomerLocation,      
		  T.CustomerPhoneNumber,  
		  T.CustomerCelullarNumber,
		  CASE WHEN CN.[AllowSentMessages] = 1 THEN 'YES' ELSE 'NO' END [CustomerReceiveMessage],
		  T.BeneficiaryName+' '+T.BeneficiaryFirstLastName+' '+ T.BeneficiarySecondLastName BeneficiaryFullName,      
		  T.BeneficiaryAddress,      
		  case       
		   when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode      
		   else B.City+' '+B.State+' '+B.Zipcode   
		  end BeneficiaryLocation,
		  case       
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
		  T.Fee,      

		--T.ExRate,  
		  ROUND(T.ExRate,2) AS ExRate, /*ticket 1523:Mantis 0001537*/

		  P.PayerName,      
		  GB.GatewayBranchCode,      
		  CASE CCu.CurrencyCode WHEN 'MXP' THEN 'MXN' ELSE CCu.CurrencyCode END AS CurrencyCode,      
		  T.AmountInMN,      
		  CCo.CountryName+' '+CCu.CurrencyName CountryCurrency,      
		  T.DepositAccountNumber,      
		  Br.BranchName,      
		  Br.Address+' '+ BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode BranchLocation,  
		  BrC.CityName as BranchCity,	--M00077-Modif. de Recibos	
		  BrS.StateName as BranchState,		--M00077-Modif. de Recibos
		  CCo.CountryName as BranchCountry, --M00077-Modif. de Recibos
		    --Case SF.State When 'OK' Then 'Oklahoma' When Null Then '' Else  SF.State End StateTax,    
		  Case SF.State 
			When 'OK' Then 'Oklahoma' 
			When Null Then 
				case 
					when dbo.fn_getStateTaxFromTransfer(@IdTransfer)>0 and a.agentstate='OK' Then 'Oklahoma' 
					when dbo.fn_getStateTaxFromTransfer(@IdTransfer)>0 and a.agentstate!='OK' Then a.agentstate 
					else 
						''
				end
			Else  SF.State 
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
		 
 
     AffiliationNoticeEnglish = 
      										--		(case 
															 --  when 
															 --    @isAgentCA = 1
															 --  then ''
															 -- else
															   ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),'')
															 --end       												
      										--		) --M00077-Modif. de Recibos
											,
		 -- ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),'') as AffiliationNoticeEnglish,
 
     AffiliationNoticeSpanish = 
      												(case 
															 --  when 
															 --    @isAgentCA = 1
															 --  then ''
															 -- else
																--CASE
																	when
																		@lenguage2=3 then ISNULL(REPLACE(AffiliationNoticePortugues, '[Agent]', A.AgentName),'')
																	else
																		ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),'')
																--END
															 end       												
      												), --M00077-Modif. de Recibos
      														 
		 -- ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),'') as AffiliationNoticeSpanish,
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
		  , AT.[AccountTypeName],

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

		   ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),'') as AffiliationNoticeSpanishJust
		   /* RESPALDO DE LA LINEA ORIGINAL QUE FUE SUSTITUIDA POR LA LINEA DE ARRIBA JFPACO 14092018
		  report.HTML_JUSTIFY(ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),'')
		   ,61, 'Consolas', 6,0,0) as AffiliationNoticeSpanishJust
		  */
		   ,EmphasizedDisclamer = Convert(BIT,CASE WHEN A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN 1 ELSE 0 END)

		   ,S.StateCode
		   ,@DisclaimerFederalEN as DisclaimerFederalEN
		   ,@DisclaimerFederalES as DisclaimerFederalES
		   ,@Disclaimer13EN as Disclaimer13EN
		   ,@Disclaimer13ES as Disclaimer13ES --M00077-Modif. de Recibos
		   ,@logo logourl
		from Transfer T       
		 inner join Agent A on A.IdAgent=T.IdAgent      
		 inner join Users U on U.IdUser = T.EnterByIdUser      
		 inner join Beneficiary B on B.IdBeneficiary =T.IdBeneficiary
		 inner join Payer P on P.IdPayer = T.IdPayer      
		 inner join PaymentType Py on Py.IdPaymentType =T.IdPaymentType      
		 inner join CountryCurrency CC on CC.IdCountryCurrency =T.IdCountryCurrency      
		 inner join Currency CCu on CCu.IdCurrency =CC.IdCurrency      
		 inner join Country CCo on CCo.IdCountry =CC.IdCountry      
		 left join Branch Br on Br.IdBranch = T.IdBranch   
		 left join City BrC on BrC.IdCity = Br.IdCity      
		 left join State BrS on BrS.IdState = BrC.IdState      
		 left join GatewayBranch GB on GB.IdBranch =T.IdBranch and GB.IdGateway = T.IdGateway      
		 left join TransferResend TR on TR.IdTransfer = T.IdTransfer      
		 left join Transfer TTR on TTR.IdTransfer = TR.IdTransfer    
		 left join StateFee SF on SF.IdTransfer=T.IdTransfer  
		 left join TransferResend TRS on TRS.IdTransfer=T.IdTransfer      
		 --LEFT JOIN dbo.[State] s ON  s.StateCode = isnull(nullif(T.CustomerState,''),A.AgentState) and s.idcountry=18
		 LEFT JOIN dbo.[State] s ON s.StateCode = isnull(A.AgentState,'') and s.idcountry=18--#1
		 LEFT JOIN StateNote n ON s.IdState = n.idstate 
         left join PureMinutesTransaction pm on t.idtransfer=pm.idtransfer and status=1
		 LEFT JOIN [Infinite].[CellularNumber] CN ON T.[CustomerCelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = @InterCode
		 LEFT JOIN [dbo].[AccountType] AT WITH (NOLOCK) ON T.[AccountTypeId] = AT.[AccountTypeId]
		 LEFT JOIN TransferModify TM WITH(NOLOCK) ON TM.NewIdTransfer = T.IdTransfer
		 where T.IdTransfer = @IdTransfer
 
 End
 Else
 Begin
		 set @ComprobanteMessage= (select top 1 1 from BrokenRulesByTransfer where IdTransfer=@IdTransfer and IdKYCAction=4 and MessageInSpanish like '%comprobante de ingresos%' )
		 Select       
		  @CorporationPhone CorporationPhone,      
		  @CorporationName CorporationName,    
		  @ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		  @ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,  
		  ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,     
		  A.AgentAddress,  
		  A.AgentCity+ ' '+ A.AgentState + ' '+ 
			REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS AgentLocation,
		  A.AgentPhone,      
		  T.Folio,   
		  (Select Top 1 Coalesce('Folio: ' + Cast(Folio as varchar(10)),'0') from Transfer with(nolock) where IdTransfer = TM.OldIdTransfer)  FolioTM,         
		  U.UserLogin,      
		  T.DateOfTransfer,        
		  T.ClaimCode,      
		  T.IdCustomer,      
		  T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName,      
		  T.CustomerAddress,      
		  T.CustomerCity+' '+ T.CustomerState+' '+
			REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') AS  CustomerLocation,      
		  T.CustomerPhoneNumber,  
  		  T.CustomerCelullarNumber,
		  CASE WHEN CN.[AllowSentMessages] = 1 THEN 'YES' ELSE 'NO' END [CustomerReceiveMessage],
		  T.BeneficiaryName+' '+T.BeneficiaryFirstLastName+' '+ T.BeneficiarySecondLastName BeneficiaryFullName,      
		  T.BeneficiaryAddress,      
		  case       
		   when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode   
		   else B.City+' '+B.State+' '+B.Zipcode    
		  end BeneficiaryLocation,
		  case       
		   when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName      
		   else B.City+' '+B.State   
		  end BeneficiaryOnlyCityState, --M00077-Modif. de Recibos
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
		  T.Fee,      

		--T.ExRate,  
		  ROUND(T.ExRate,2) AS ExRate, /*ticket 1523:Mantis 0001537*/

		  P.PayerName,      
		  GB.GatewayBranchCode,      
		  CASE CCu.CurrencyCode WHEN 'MXP' THEN 'MXN' ELSE CCu.CurrencyCode END AS CurrencyCode,   
		  T.AmountInMN,      
		  CCo.CountryName+' '+CCu.CurrencyName CountryCurrency,      
		  T.DepositAccountNumber,      
		  Br.BranchName,     
		  Br.Address+' '+ BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode BranchLocation,  
		  BrC.CityName as BranchCity,		 --M00077-Modif. de Recibos
		  BrS.StateName as BranchState,		
		  CCo.CountryName as BranchCountry,   --M00077-Modif. de Recibos
		  Case SF.State When 'OK' Then 'Oklahoma' When Null Then '' Else  SF.State End StateTax,    
		  Isnull(SF.Tax,0) as Tax,  
		  Case When TRS.NewIdTransfer IS NULL  Then @NotResend else @Resend End as IsResend,
		  @ComprobanteMessage  ComprobanteMessage,
		  ISNULL(n.[ComplaintNoticeEnglish],'') as ComplaintNoticeEnglish,
		  ISNULL(n.[ComplaintNoticeSpanish],'') as ComplaintNoticeSpanish,
		  ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),'') as AffiliationNoticeEnglish,
		  ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),'') as AffiliationNoticeSpanish,
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
		  , AT.[AccountTypeName],

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
		  report.HTML_JUSTIFY(ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),'')
		   ,61, 'Consolas', 6,0,0) as AffiliationNoticeSpanishJust
		   ,EmphasizedDisclamer = Convert(BIT,CASE WHEN A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN 1 ELSE 0 END)
		   ,S.StateCode
		   ,@DisclaimerFederalEN as DisclaimerFederalEN
		   ,@DisclaimerFederalES as DisclaimerFederalES
		   ,@Disclaimer13EN as Disclaimer13EN
		   ,@Disclaimer13ES as Disclaimer13ES --M00077-Modif. de Recibos
		   ,@logo logourl
		from TransferClosed T       
		 inner join Agent A on A.IdAgent=T.IdAgent      
		 inner join Users U on U.IdUser = T.EnterByIdUser      
		 inner join Beneficiary B on B.IdBeneficiary =T.IdBeneficiary      
		 inner join Payer P on P.IdPayer = T.IdPayer      
		 inner join PaymentType Py on Py.IdPaymentType =T.IdPaymentType      
		 inner join CountryCurrency CC on CC.IdCountryCurrency =T.IdCountryCurrency      
		 inner join Currency CCu on CCu.IdCurrency =CC.IdCurrency      
		 inner join Country CCo on CCo.IdCountry =CC.IdCountry      
		 left join Branch Br on Br.IdBranch = T.IdBranch      
		 left join City BrC on BrC.IdCity = Br.IdCity      
		 left join [State] BrS on BrS.IdState = BrC.IdState      
		 left join GatewayBranch GB on GB.IdBranch =T.IdBranch and GB.IdGateway = T.IdGateway      
		 left join TransferResend TR on TR.IdTransfer = T.IdTransferClosed      
		 left join [Transfer] TTR on TTR.IdTransfer = TR.IdTransfer    
		 left join StateFee SF on SF.IdTransfer=T.IdTransferClosed  
		 left join TransferResend TRS on TRS.IdTransfer=T.IdTransferClosed      
		 --LEFT JOIN dbo.[State] s ON  s.StateCode = isnull(nullif(T.CustomerState,''),A.AgentState) and s.idcountry=18
		 LEFT JOIN dbo.[State] s ON s.StateCode = isnull(A.AgentState,'') and s.idcountry=18--#1
		 LEFT JOIN StateNote n ON s.IdState = n.idstate  
         left join PureMinutesTransaction pm on t.IdTransferClosed=pm.idtransfer and [status]=1
		 LEFT JOIN [Infinite].[CellularNumber] CN ON T.[CustomerCelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = @InterCode
		 LEFT JOIN [dbo].[AccountType] AT WITH (NOLOCK) ON T.[AccountTypeId] = AT.[AccountTypeId]
		 LEFT JOIN TransferModify TM WITH(NOLOCK) ON TM.NewIdTransfer = T.IdTransferClosed
		 where T.IdTransferClosed = @IdTransfer     

 
 
		 End

CREATE procedure [dbo].[st_GetTransactionCancelReceipt](@IdTransfer int, @IdCountryOrigin int, @IdCountryDestiny int)    
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
    <log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
    <log Date="25/08/2020" Author="adominguez">Se agrega validacion para que muestre reembolso total cuando es sattus rejected</log> --# 1
    <log Date="2022-04-18" Author="jcsierra"> Se modifica la columna AmountToReimburse para considerar el descuento, tambien se agrega la columna Discount </log>
    <log Date="2022-05-23" Author="jcsierra"> Se agregan columnas (TypeOfService, DateAvailable, RefundMethod, TimeZoneAbbr, PrintDateTime) </log>
	<log Date="2022/07/04" Author="saguilar">Se agrega funcion para conversion de hora local por agente </log>
	<log Date="2022/07/6" Author="jcsierra">Se realiza Merge entre cambios de recibos y UTC</log>
	<log Date="2022/07/12" Author="jcsierra">Se muestran los numeros de cel en lugar del numero de telefono</log>
	<log Date="2022/07/19" Author="jcsierra">Se replica columna BeneficiaryAddress de [st_GetTransactionReceipt]</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
    
declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      

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

--ReceiptTransferCancelMessage
declare @ReceiptTransferCancelEnglishMessage varchar(max)      
declare @ReceiptTransferCancelSpanishMessage varchar(max)      

select @ReceiptTransferCancelEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferCancelMessage'),
       @ReceiptTransferCancelSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ReceiptTransferCancelMessage')


DECLARE @IdCountryUSA	INT,
		@IdCurrencyUSA	INT,
		@MinutsToWait	INT,
		@IdCountryVNM	INT,
		@IdCountryPHL	INT

SET @IdCountryUSA = dbo.GetGlobalAttributeByName('IdCountryUSA')
SET @IdCountryVNM = dbo.GetGlobalAttributeByName('IdCountryVNM')
SET @IdCountryPHL = dbo.GetGlobalAttributeByName('IdCountryPHL')
SET @IdCurrencyUSA = dbo.GetGlobalAttributeByName('IdCurrencyUSA')
SET @MinutsToWait = dbo.GetGlobalAttributeByName('TimeFromReadyToAttemp')

--- Conversion Hora Local 

Declare @receiptType int = 2

	   Select DateOfTransferLocal,
			  PrintedDate,
			  TimeZone

		into #LocalTime                       
			 from [dbo].[FnConvertLocalTimeZoneCancel] (@IdTransfer,@receiptType) -- Se invoca Funcion Timezone
		
	Declare @LocalDate datetime,
			@PrintedDate datetime,
			@TimeZone nvarchar(3)

	 select @LocalDate=DateOfTransferLocal,
	        @TimeZone=TimeZone,
			@PrintedDate=PrintedDate
	 from #LocalTime
		
		Drop table #LocalTime
				

--- Termina Conversion

If Exists(Select 1 From [Transfer] with(nolock) where IdTransfer=@IdTransfer)      
Begin  
select     
@CorporationPhone CorporationPhone,  
--@ReceiptTransferCancelEnglishMessage ReceiptTransferCancelEnglishMessage,
NULL ReceiptTransferCancelEnglishMessage,
--IIF(Cco.IdCountry IN (@IdCountryPHL, @IdCountryVNM), 
--'', 
--@ReceiptTransferCancelSpanishMessage) ReceiptTransferCancelSpanishMessage,
NULL ReceiptTransferCancelSpanishMessage,
  A.AgentCode + ' '+ A.AgentName as AgentName,    
  A.AgentAddress,    
  A.AgentCity+ ' '+ A.AgentState + ' '+ 
	REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0')  AgentLocation,    
  A.AgentPhone,    
  T.Folio,     
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
  T.CustomerCity+' '+ T.CustomerState+' '+REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') CustomerLocation,    
  T.CustomerCelullarNumber CustomerPhoneNumber,  
  Case When T.CustomerIdCarrier<>0 Then 'YES' Else 'NO' End As CustomerReceiveMessage,     
  T.BeneficiaryName+' '+T.BeneficiaryFirstLastName+' '+ T.BeneficiarySecondLastName BeneficiaryFullName,   
  
			LTRIM(
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
			) BeneficiaryAddress,   
  case     
   when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode    
   else B.City+' '+B.[State]+' '+B.Zipcode    
  end BeneficiaryLocation,    
  T.BeneficiaryCelularNumber BeneficiaryPhoneNumber,  
  T.BeneficiaryCountry,
  T.AmountInDollars,    
  T.Fee - T.Discount Fee,
 Case SF.[State] When 'OK' Then 'Oklahoma' When Null Then '' Else  SF.[State] End StateTax,  
  Isnull(SF.Tax,0) as Tax,  
  0.0 CancelationCharge,  
		CASE 
			WHEN T.IdStatus = 31 THEN T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) - T.Discount--# 1
			ELSE
				CASE 
					WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) - T.Discount
					WHEN TN.IdTransfer is not null then T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) - T.Discount
					ELSE CASE (rc.returnallcomission) 
                        WHEN 1 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) - T.Discount
                        ELSE T.AmountInDollars
					END
				END       
			END
    --end 
    AmountToReimburse,
	CASE 
		WHEN T.IdStatus = 31 THEN '+'--# 1
		ELSE
			CASE 
				WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then '+'
				WHEN TN.IdTransfer is not null then '+'
				ELSE CASE (rc.returnallcomission) 
					WHEN 1 THEN '+'
					ELSE ''
				END
			END       
	END RefundSign,
    DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange) TransferMinutes ,
    isnull(R.Reason,'') Reason,
    T.Discount,
	--CONCAT(
	--	CASE CC.IdCountry
	--		WHEN @IdCountryUSA THEN 'Domestic'
	--		WHEN @IdCountryVNM THEN Cco.CountryName
	--		WHEN @IdCountryPHL THEN Cco.CountryName
	--		ELSE 'International'
	--	END,
	--	' Money Transmission ',
	--	CASE 
	--		WHEN (DATEDIFF(MINUTE, T.DateOfTransfer, T.DateStatusChange) >= 30) THEN '(After 30 minutes)'
	--		ELSE '(Within 30 minutes)'
	--	END
	--) TypeOfService,
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
	FORMAT(t.DateStatusChange, 'd') DateAvailable,
	'Cash' RefundMethod,
	@TimeZone TimeZoneAbbr,
	@PrintedDate PrintDate,
	'' AccountTypeName
from [Transfer] T with(nolock)     
 inner join Agent A with(nolock) on A.IdAgent=T.IdAgent    
 inner join Users U with(nolock) on U.IdUser = T.EnterByIdUser    
 inner join Beneficiary B with(nolock) on B.IdBeneficiary =T.IdBeneficiary    
 inner join Payer P with(nolock) on P.IdPayer = T.IdPayer    
 inner join PaymentType Py with(nolock) on Py.IdPaymentType =T.IdPaymentType    
 inner join CountryCurrency CC with(nolock) on CC.IdCountryCurrency =T.IdCountryCurrency    
 inner join Currency CCu with(nolock) on CCu.IdCurrency =CC.IdCurrency    
 inner join Country CCo with(nolock) on CCo.IdCountry =CC.IdCountry    
 left join Branch Br with(nolock) on Br.IdBranch = T.IdBranch    
 left join City BrC with(nolock) on BrC.IdCity = Br.IdCity    
 left join [State] BrS with(nolock) on BrS.IdState = BrC.IdState    
left join Country BrCt on BrCt.IdCountry = BrS.IdCountry
 left join GatewayBranch GB with(nolock) on GB.IdBranch =T.IdBranch and GB.IdGateway = T.IdGateway    
 left join TransferResend TR with(nolock) on TR.IdTransfer = T.IdTransfer
 left join [Transfer] TTR with(nolock) on TTR.IdTransfer = TR.IdTransfer    
 left join StateFee SF with(nolock) on SF.IdTransfer=T.IdTransfer
 left join TransferNotAllowedResend TN with(nolock) on TN.IdTransfer =T.IdTransfer  
 Left join ReasonForCancel R with(nolock) on R.IdReasonForCancel=T.IdReasonForCancel
 left join reasonforcancel rc with(nolock) on t.idreasonforcancel=rc.idreasonforcancel

 where T.IdTransfer = @IdTransfer    
     
End
Else
Begin
select     
@CorporationPhone CorporationPhone,  
@ReceiptTransferCancelEnglishMessage ReceiptTransferCancelEnglishMessage,
IIF(Cco.IdCountry IN (@IdCountryPHL, @IdCountryVNM), '', @ReceiptTransferCancelSpanishMessage) ReceiptTransferCancelSpanishMessage, 
  A.AgentCode + ' '+ A.AgentName as AgentName,   
  A.AgentAddress,    
  A.AgentCity+ ' '+ A.AgentState + ' '+ 
	REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0')  AgentLocation,    
  A.AgentPhone,    
  T.Folio,     
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
  T.CustomerCity+' '+ T.CustomerState+' '+REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') CustomerLocation,    
  T.CustomerPhoneNumber,  
  Case When T.CustomerIdCarrier<>0 Then 'YES' Else 'NO' End As CustomerReceiveMessage,    
  T.BeneficiaryName+' '+T.BeneficiaryFirstLastName+' '+ T.BeneficiarySecondLastName BeneficiaryFullName,    
  LTRIM(
	CONCAT(
		IIF(ISNULL(T.BeneficiaryAddress, '') <> '', CONCAT(T.BeneficiaryAddress, ', ', T.BeneficiaryCity), ''),
		' ',
		CASE 
			WHEN ISNULL(T.BeneficiaryState, '') <> '' THEN T.BeneficiaryState
			ELSE BrS.StateName
		END, 
		' ',
		IIF(T.BeneficiaryCity='', Br.zipcode, B.Zipcode),
		' ',
		CASE 
			WHEN ISNULL(T.BeneficiaryCountry, '') <> '' THEN T.BeneficiaryCountry
			WHEN BrCt.IdCountry IS NOT NULL THEN BrCt.CountryName
			ELSE CCo.CountryName
		END
	)) BeneficiaryAddress,   
  case     
   when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode    
   else B.City+' '+B.[State]+' '+B.Zipcode
  end BeneficiaryLocation,    
  T.BeneficiaryPhoneNumber,  
  T.BeneficiaryCountry,
  T.AmountInDollars,    
  T.Fee,    
 Case SF.[State] When 'OK' Then 'Oklahoma' When Null Then '' Else  SF.[State] End StateTax,  
  Isnull(SF.Tax,0) as Tax,  
  0.0 CancelationCharge,  
    CASE 
        WHEN T.IdStatus = 31 THEN T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) - T.Discount --# 1
        ELSE
            CASE 
                WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then  T.AmountInDollars+T.Fee+ Isnull(SF.Tax,0) - T.Discount
                when TN.IdTransfer is not null then T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) - T.Discount
                ELSE CASE (rc.returnallcomission) 
                    WHEN 1 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) - T.Discount
                    ELSE T.AmountInDollars
                END
            END     
        END
    AmountToReimburse,
    DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange) TransferMinutes,
    isnull(R.Reason,'') Reason,
    T.Discount,
	CONCAT(
		'Money Transmission (',
		CASE CC.IdCountry
			WHEN @IdCountryUSA THEN 'Domestic'
			WHEN @IdCountryVNM THEN Cco.CountryName
			WHEN @IdCountryPHL THEN Cco.CountryName
			ELSE 'International'
		END,
		') ',
		CASE 
			WHEN (DATEDIFF(MINUTE, T.DateOfTransfer, T.DateStatusChange) >= 30) THEN '(After 30 minutes)'
			ELSE '(Within 30 minutes)'
		END
	) TypeOfService,
	FORMAT(t.DateStatusChange, 'd') DateAvailable,
	'Cash' RefundMethod,
	@TimeZone TimeZoneAbbr,
	@PrintedDate PrintDate,
	'' AccountTypeName
from TransferClosed T with(nolock)     
 inner join Agent A with(nolock) on A.IdAgent=T.IdAgent    
 inner join Users U with(nolock) on U.IdUser = T.EnterByIdUser    
 inner join Beneficiary B with(nolock) on B.IdBeneficiary =T.IdBeneficiary    
 inner join Payer P with(nolock) on P.IdPayer = T.IdPayer    
 inner join PaymentType Py with(nolock) on Py.IdPaymentType =T.IdPaymentType    
 inner join CountryCurrency CC with(nolock) on CC.IdCountryCurrency =T.IdCountryCurrency    
 inner join Currency CCu with(nolock) on CCu.IdCurrency =CC.IdCurrency    
 inner join Country CCo with(nolock) on CCo.IdCountry =CC.IdCountry    
 left join Branch Br with(nolock) on Br.IdBranch = T.IdBranch    
 left join City BrC with(nolock) on BrC.IdCity = Br.IdCity    
 left join [State] BrS on BrS.IdState = BrC.IdState   
 		left join Country BrCt on BrCt.IdCountry = BrS.IdCountry
 left join GatewayBranch GB with(nolock) on GB.IdBranch =T.IdBranch and GB.IdGateway = T.IdGateway    
 left join TransferResend TR with(nolock) on TR.IdTransfer = T.IdTransferClosed 
 left join [Transfer] TTR with(nolock) on TTR.IdTransfer = TR.IdTransfer      
 left join StateFee SF with(nolock) on SF.IdTransfer=T.IdTransferClosed  
 left join TransferNotAllowedResend TN with(nolock) on TN.IdTransfer =T.IdTransferClosed
 Left join ReasonForCancel R with(nolock) on R.IdReasonForCancel=T.IdReasonForCancel
 left join reasonforcancel rc with(nolock) on t.idreasonforcancel=rc.idreasonforcancel
 Where T.IdTransferClosed = @IdTransfer    
    

End


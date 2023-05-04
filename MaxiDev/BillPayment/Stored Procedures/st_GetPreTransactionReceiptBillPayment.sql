
CREATE procedure [BillPayment].[st_GetPreTransactionReceiptBillPayment](

--@IdTransfer int, 





@AccountNumber varchar(20),

@BillerDescription varchar(max),--",data.Biller.Name},

@CustomerFullName varchar(max),--",data.CurrentCustomer.FirstName + " " + data.CurrentCustomer.LastName},

@ExRate varchar(10),--",data.ExRateMaxi.ToString()},

@Fee varchar(10),--",data.Fee.ToString()},

@NameOnAccount varchar(max),--",data.NameOnAccount != null ? data.NameOnAccount : string.Empty},

--@AffiliationNoticeEnglish varchar(max),--",string.Empty},

--@AffiliationNoticeSpanish varchar(max),--",string.Empty},

@IdAgent int,--",SystemContext.AgentDefault.IdAgent.ToString()},

--@CurrencyName varchar(max),--", data.Currency},

--@Amount varchar(10),--", data.AmountUsd.ToString()},

@AmountInMn varchar(10),--", _viewModel.AmountForeignCurrency.ToString()},

--@HavePreReceipt varchar(10),--", havePreReceipt.ToString()},

@User varchar(50),

@IdCountryOrigin int, 

@IdBiller int,

@CurrencyCode varchar(50)

--@IdCountryDestiny int

)


as      

/********************************************************************
<Author> ??? </Author>
<app> Agent, Corporative </app>
<Description> Gets print information for Tickets and PreRecepits</Description>
<ChangeLog>
<log Date="02/10/2017" Author="jmoreno">California Disclamer.</log>
</ChangeLog>
*********************************************************************/      
--jmoreno

declare @IdCountryDestiny int


if(Select count(*)from BillPayment.Billers (nolock) where IdBiller = @IdBiller  and IsDomestic = 1 ) > 0

Begin

	set @IdCountryDestiny = (Select IdCountry from Country (nolock) where CountryCode = 'USA')

end

--else

--begin

---Descomentar cuando se tenga la tabla de biller que no sean domesticos

--end

DECLARE @BoldDisclamerStates Table (AgentState VARCHAR(10))

INSERT INTO  @BoldDisclamerStates VALUES ('CA')      

declare @CorporationPhone varchar(50)      

set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      

declare @CorporationName varchar(50)      

set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');

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







--BeneficiaryMirror



declare @TopBeneficiaryMirrorid int



declare @IdTransferFromPreTransfer int



declare @BeneficiaryMirrorFullName nvarchar(max)



declare @BeneficiaryMirrorAddress nvarchar(max)



declare @BeneficiaryMirrorLocation nvarchar(max)



declare @BeneficiaryMirrorPhoneNumber nvarchar(max)



declare @BeneficiaryMirrorCountry nvarchar(max)







--select @IdTransferFromPreTransfer = IdTransfer from PreTransfer where IdPreTransfer = @IdTransfer; 







--IF exists(Select 1 from BeneficiaryMirror where IdTransfer = @IdTransferFromPreTransfer)



--	BEGIN



--		select @TopBeneficiaryMirrorid = max(IdBeneficiaryMirror) from BeneficiaryMirror where IdTransfer = @IdTransferFromPreTransfer; 







--		select top 1 @BeneficiaryMirrorFullName = Name + ' ' + FirstLastName + ' ' + SecondLastName, 



--					 @BeneficiaryMirrorAddress = Address,



--					 @BeneficiaryMirrorLocation = City + ' ' + State + ' ' + Zipcode,



--					 @BeneficiaryMirrorPhoneNumber = PhoneNumber, 



--					 @BeneficiaryMirrorCountry = Country 



--					 from BeneficiaryMirror 



--					 where IdTransfer = @IdTransferFromPreTransfer



--					 and IdBeneficiaryMirror = @TopBeneficiaryMirrorid; 



--	END



--ELSE



--	BEGIN



		set @BeneficiaryMirrorFullName = NULL



		set @BeneficiaryMirrorAddress = NULL



		set @BeneficiaryMirrorLocation = NULL



		set @BeneficiaryMirrorPhoneNumber = NULL



		set @BeneficiaryMirrorCountry = NULL



	--END 



 



		--set @ComprobanteMessage = ISNULL((select top 1 1 from BrokenRulesByTransfer where IdTransfer=@IdTransfer and IdKYCAction=4 and MessageInSpanish like '%comprobante de ingresos%' ),'')







		Select       



		  @CorporationPhone CorporationPhone,      



		  @CorporationName CorporationName,    



		  @PreTransferEnglishMessage PreTransferEnglishMessage,



		  @PreTransferSpanishMessage PreTransferSpanishMessage,  



		  A.AgentCode+' '+ A.AgentName AgentName,      



		  A.AgentAddress,      



		  A.AgentCity+ ' '+ A.AgentState + ' '+ 



			REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AgentLocation,



		  A.AgentPhone,      



		  0 as Folio,       



		  @User UserLogin,      



		  GETDATE() DateOfPreTransfer,     



		  0 IdCustomer,      



		  @CustomerFullName CustomerFullName,      



		  --'' CustomerAddress,      



		 ---- T.CustomerCity+' '+ T.CustomerState+' '+



			----REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') AS  CustomerLocation,      

		  --'' CustomerLocation,



		  --'' CustomerPhoneNumber,  



		  --'' CustomerCelullarNumber,



		  --'' CustomerReceiveMessage,--Case When T.CustomerIdCarrier<>0 Then 'YES' Else 'NO' End As CustomerReceiveMessage,    



		  --'' BeneficiaryFullName, --T.BeneficiaryName+' '+T.BeneficiaryFirstLastName+' '+ T.BeneficiarySecondLastName BeneficiaryFullName,      



		  --'' BeneficiaryAddress,      



		  ----case       



		  ---- when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode    



		  ---- else B.City+' '+B.State+' '+B.Zipcode     



		  ----end BeneficiaryLocation,    

		  --'' BeneficiaryLocation,  



		  --'' BeneficiaryPhoneNumber,    



		  --'' BeneficiaryCountry,



		  --Prueba Beneficiary Mirror



		  @BeneficiaryMirrorFullName BeneficiaryMirrorFullName,



		  @BeneficiaryMirrorAddress BeneficiaryMirrorAddress,



		  @BeneficiaryMirrorLocation BeneficiaryMirrorLocation, 



		  @BeneficiaryMirrorPhoneNumber BeneficiaryMirrorPhoneNumber,



		  @BeneficiaryMirrorCountry BeneficiaryMirrorCountry,



		  --Termina prueba Beneficiary Mirror       



		  'Payment Name ---' PaymentName,      



		  Convert(decimal(5,2),@AmountInMN) AmountInDollars,      



		  Convert(decimal(5,2),@Fee) Fee,      



		  Convert(decimal(5,2),@ExRate) ExRate,      



		  @BillerDescription PayerName,      



		  --'' GatewayBranchCode,      



		  @CurrencyCode CurrencyCode,      



		  Convert(decimal(5,2),@AmountInMN) AmountInMN,      



		  --'' CountryCurrency, --CCo.CountryName+' '+CCu.CurrencyName CountryCurrency,      



		  @AccountNumber DepositAccountNumber,      



		  'BranchName' BranchName,      



		  'BranhLocation' BranchLocation,--Br.Address+' '+ BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode BranchLocation,    



		  ISNULL(Case a.Agentstate



            When 'OK' Then 'Oklahoma' 



            When NULL Then '' 



            Else a.Agentstate



          END,'') StateTax,



		  0 Tax, --Isnull(t.statetax,dbo.fn_getStateTaxFromTransfer(@IdTransfer)) as Tax,



		  --Case When TRS.NewIdTransfer IS NULL  Then @NotResend else @Resend End as IsResend,



		  @ComprobanteMessage as ComprobanteMessage,



          @DisclaimerES01 DisclaimerES01,



          @DisclaimerEn01 DisclaimerEn01,



          @DisclaimerES02 DisclaimerES02,



          @DisclaimerEn02 DisclaimerEn02,



          @DisclaimerES03 DisclaimerES03,



          @DisclaimerEn03 DisclaimerEn03,



		  --case



		  --when T.IdGateway=4 and T.IdPaymentType in (1,4) and T.IdCountryCurrency=@IdCountryCurrencyMexicoPesos and T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars*T.ExRate,2) then '*** ' + @DisclaimerEN07 + '.'

		  --else ''

		  --end DisclaimerEn07,

		  '' DisclaimerEn07,

		  --case

		  --when T.IdGateway=4 and T.IdPaymentType in (1,4) and T.IdCountryCurrency=@IdCountryCurrencyMexicoPesos and T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars*T.ExRate,2) then '*** ' + @DisclaimerEs07 + '.'

		  --else ''

		  --end DisclaimerEs07

		  '' DisclaimerEs07,

		  'AccountTypeName' [AccountTypeName],

		    report.HTML_JUSTIFY(@DisclaimerEn01 + '*** '+ @DisclaimerEn02 + '*** '+ @DisclaimerEn03 + @DisclaimerEN07,

		  61, 'Consolas', 7,0,0) AS EngMessPreReceipt,

		  report.HTML_JUSTIFY(@DisclaimerES01 + '*** '+ @DisclaimerES02 + '*** '+ @DisclaimerES03 + @DisclaimerES07, 61, 'Consolas', 7,0,0) AS SpaMessPreReceipt ,

		  EmphasizedDisclamer = Convert(BIT,CASE WHEN A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN 1 ELSE 0 END)

		 from Agent A 

		 where IdAgent = @IdAgent

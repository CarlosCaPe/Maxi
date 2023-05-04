CREATE procedure [dbo].[st_GetTransactionUnclaimedReceipt](@IdTransfer int)      
as      
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
   
declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');   
 
 
declare @ReceiptTransferEnglishMessage varchar(max)      
set @ReceiptTransferEnglishMessage = dbo.GetGlobalAttributeByName('ReceiptTransferEnglishMessage');   

declare @ReceiptTransferSpanishMessage varchar(max)      
set @ReceiptTransferSpanishMessage = dbo.GetGlobalAttributeByName('ReceiptTransferSpanishMessage');   
  
Declare @Resend bit  
Set @Resend=1  
Declare @NotResend bit  
Set @NotResend=0  

If exists (Select 1 from TransfersUnclaimed with(nolock) where IdTransfer=@IdTransfer and IdStatus=2)
BEGIN 
 
	If exists(Select 1 from [Transfer] with(nolock) where IdTransfer=@IdTransfer)    
	Begin
		Select       
		  @CorporationPhone CorporationPhone,      
		  @CorporationName CorporationName,    
		  @ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		  @ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,  
		  A.AgentCode+' '+ A.AgentName AgentName,      
		  A.AgentAddress,      
		  A.AgentCity+ ' '+ A.AgentState + ' '+ REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AgentLocation,      
		  A.AgentPhone,      
		  T.Folio,       
		  U.UserLogin,      
		  T.DateOfTransfer,        
		  T.ClaimCode,      
		  T.IdCustomer,      
		  T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName,      
		  T.CustomerAddress,      
		  T.CustomerCity+' '+ T.CustomerState+' '+REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') CustomerLocation,      
		  T.CustomerPhoneNumber,  
		  Case When T.CustomerIdCarrier<>0 Then 'YES' Else 'NO' End As CustomerReceiveMessage,    
		  T.BeneficiaryName+' '+T.BeneficiaryFirstLastName+' '+ T.BeneficiarySecondLastName BeneficiaryFullName,      
		  T.BeneficiaryAddress,      
		  case       
		   when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode      
		   else B.City+' '+B.[State]+' '+B.Zipcode      
		  end BeneficiaryLocation,      
		  T.BeneficiaryPhoneNumber,    
		  T.BeneficiaryCountry,    
		  Py.PaymentName,      
		  T.AmountInDollars,      
		  T.Fee,      
		  T.ExRate,      
		  P.PayerName,      
		  GB.GatewayBranchCode,      
		  CCu.CurrencyCode,      
		  T.AmountInMN,      
		  CCo.CountryName+' '+CCu.CurrencyName CountryCurrency,      
		  T.DepositAccountNumber,      
		  Br.BranchName,      
		  Br.[Address]+' '+ BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode BranchLocation,    
		  Case SF.[State] When 'OK' Then 'Oklahoma' When Null Then '' Else  SF.[State] End StateTax,    
		  Isnull(SF.Tax,0) as Tax,  
		  Case When TRS.NewIdTransfer IS NULL  Then @NotResend else @Resend End as IsResend   
		          
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
		 left join GatewayBranch GB with(nolock) on GB.IdBranch =T.IdBranch and GB.IdGateway = T.IdGateway      
		 left join TransferResend TR with(nolock) on TR.IdTransfer = T.IdTransfer      
		 left join [Transfer] TTR with(nolock) on TTR.IdTransfer = TR.IdTransfer    
		 left join StateFee SF with(nolock) on SF.IdTransfer=T.IdTransfer  
		 left join TransferResend TRS with(nolock) on TRS.IdTransfer=T.IdTransfer      
		 where T.IdTransfer = @IdTransfer     
	End
	Else
	Begin
		Select       
	  @CorporationPhone CorporationPhone,      
	  @CorporationName CorporationName,    
	  @ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
	  @ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,  
	  ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,     
	  A.AgentAddress,      
	  A.AgentCity+ ' '+ A.AgentState + ' '+ A.AgentZipcode AgentLocation,      
	  A.AgentPhone,      
	  T.Folio,       
	  U.UserLogin,      
	  T.DateOfTransfer,        
	  T.ClaimCode,      
	  T.IdCustomer,      
	  T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName,      
	  T.CustomerAddress,      
	  T.CustomerCity+' '+ T.CustomerState+' '+T.CustomerZipcode CustomerLocation,      
	  T.CustomerPhoneNumber,  
	  Case When T.CustomerIdCarrier<>0 Then 'YES' Else 'NO' End As CustomerReceiveMessage,    
	  T.BeneficiaryName+' '+T.BeneficiaryFirstLastName+' '+ T.BeneficiarySecondLastName BeneficiaryFullName,      
	  T.BeneficiaryAddress,      
	  case       
	   when T.BeneficiaryCity='' then BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode      
	   else B.City+' '+B.State+' '+B.Zipcode      
	  end BeneficiaryLocation,      
	  T.BeneficiaryPhoneNumber,    
	  T.BeneficiaryCountry,    
	  Py.PaymentName,      
	  T.AmountInDollars,      
	  T.Fee,      
	  T.ExRate,      
	  P.PayerName,      
	  GB.GatewayBranchCode,      
	  CCu.CurrencyCode,      
	  T.AmountInMN,      
	  CCo.CountryName+' '+CCu.CurrencyName CountryCurrency,      
	  T.DepositAccountNumber,      
	  Br.BranchName,      
	  Br.[Address]+' '+ BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode BranchLocation,    
	  Case SF.[State] When 'OK' Then 'Oklahoma' When Null Then '' Else  SF.[State] End StateTax,    
	  Isnull(SF.Tax,0) as Tax,  
	  Case When TRS.NewIdTransfer IS NULL  Then @NotResend else @Resend End as IsResend   
	          
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
	 left join [State] BrS with(nolock) on BrS.IdState = BrC.IdState      
	 left join GatewayBranch GB with(nolock) on GB.IdBranch =T.IdBranch and GB.IdGateway = T.IdGateway      
	 left join TransferResend TR with(nolock) on TR.IdTransfer = T.IdTransferClosed      
	 left join [Transfer] TTR with(nolock) on TTR.IdTransfer = TR.IdTransfer    
	 left join StateFee SF with(nolock) on SF.IdTransfer=T.IdTransferClosed  
	 left join TransferResend TRS with(nolock) on TRS.IdTransfer=T.IdTransferClosed      
	 where T.IdTransferClosed = @IdTransfer     
	End
 
END


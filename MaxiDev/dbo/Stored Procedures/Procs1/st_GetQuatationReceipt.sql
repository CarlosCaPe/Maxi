

CREATE PROCEDURE [dbo].[st_GetQuatationReceipt](@IdAgent int, @IdCountryOrigin int, @IdCountryDestiny int, @IdPayer int, @IdBranch int, @IdPaymentType int, @IdCity int, @IdCountryCurrency int, @IdGateway int, @OriginAmountInMN Money, @AmountInMN Money, @AccountTypeId INT = NULL)
as


/********************************************************************
<Author> ??? </Author>
<app> Agent, Corporative </app>
<Description> Gets print information for Tickets and Recepits</Description>

<ChangeLog>
<log Date="03/10/2017" Author="jmoreno">California Disclamer.</log>
</ChangeLog>

*********************************************************************/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


DECLARE @BoldDisclamerStates Table (AgentState VARCHAR(10))
INSERT INTO  @BoldDisclamerStates VALUES ('CA')


--declaracion de variables      
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
declare @DisclaimerEN01 nvarchar(max)
declare @DisclaimerEN02 nvarchar(max)
declare @DisclaimerEN03 nvarchar(max)
declare @DisclaimerEN04 nvarchar(max)
declare @DisclaimerEN05 nvarchar(max)
declare @DisclaimerEN06 nvarchar(max)
declare @DisclaimerEN07 nvarchar(max)

-----mensajes 
   
select @ReceiptTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferMessage'),   
       @ReceiptTransferSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ReceiptTransferMessage'),
       @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1'),
       @DisclaimerEN02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer2'),
       @DisclaimerEN03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer3'),
       @DisclaimerEN04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer4'),
       @DisclaimerEN05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer5'),
       @DisclaimerEN06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer6'),
	   @DisclaimerEN07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer7'),
       @DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer1'),
       @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer2'),
       @DisclaimerES03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer3'),
       @DisclaimerES04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer4'),
       @DisclaimerES05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer5'),
       @DisclaimerES06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer6'),
	   @DisclaimerES07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer7')


----- Special case when Idbranch is null but transfer is cash ----------------                                                            
declare @BranchName nvarchar(max)
declare @BranchLocation nvarchar(max)

If (@IdBranch is null and (@IdPaymentType=1 or @IdPaymentType=4 or @IdPaymentType=2))                                                            
Begin                                 
 If @IdCity is Null                                
 Begin                                
  Select top 1 @IdBranch=IdBranch from Branch where IdPayer=@IdPayer and (IdGenericStatus=1 or IdGenericStatus is null)  order by IdBranch                                                       
  select * from branch
  Select @BranchName=branchname,@BranchLocation=Address from branch where IdBranch=@IdBranch
 End                                
 Else                                
 Begin                
  Select top 1 @IdBranch=IdBranch from Branch where IdPayer=@IdPayer and (IdGenericStatus=1 or IdGenericStatus is null) and IdCity=@IdCity order by IdBranch                                                       
  Select @BranchName=branchname,@BranchLocation=Address from branch where IdBranch=@IdBranch
 End                                
End  
  
-- Check Again IdBranch in case @IdCity was not null but not exists  
  
If (@IdBranch is null and (@IdPaymentType=1 or @IdPaymentType=4 or @IdPaymentType=2))                                                            
Begin                                 
  Select top 1 @IdBranch=IdBranch from Branch where IdPayer=@IdPayer and (IdGenericStatus=1 or IdGenericStatus is null)  order by IdBranch                                                       
  Select @BranchName=branchname,@BranchLocation=Address from branch where IdBranch=@IdBranch
  Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) values ('st_GetQuatationReceipt',GETDATE(),' Y el IdPayer es '+CONVERT(Varchar,@IdPayer))      
End

DECLARE @AccountType NVARCHAR(MAX) = ''

IF @AccountTypeId IS NOT NULL
	SELECT @AccountType = [AccountTypeName] FROM [dbo].[AccountType] WITH (NOLOCK) WHERE [AccountTypeId] = @AccountTypeId

Select       
		  @CorporationPhone CorporationPhone,      
		  @CorporationName CorporationName,    
		  @ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		  @ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,  
		  A.AgentCode+' '+ A.AgentName AgentName,      
		  A.AgentAddress,      
		  A.AgentCity+ ' '+ A.AgentState + ' '+ REPLACE(STR(isnull(a.agentzipcode,0), 5), SPACE(1), '0') AgentLocation,      
		  A.AgentPhone,		  
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
          isnull(@BranchName,'') BranchName,
          isnull(@BranchLocation,'') BranchLocation
		   ,case
		  when @IdGateway=4 and @IdPaymentType in (1,4) and @IdCountryCurrency=@IdCountryCurrencyMexicoPesos and @AmountInMN <> @OriginAmountInMN then '*** ' + @DisclaimerEN07 + '.'
		  else ''
		  end DisclaimerEn07,
		  case
		  when @IdGateway=4 and @IdPaymentType in (1,4) and @IdCountryCurrency=@IdCountryCurrencyMexicoPesos and @AmountInMN <> @OriginAmountInMN then '*** ' + @DisclaimerEs07 + '.'
		  else ''
		  end DisclaimerEs07
		  , @AccountType [AccountType]
		  ,EmphasizedDisclamer = Convert(BIT,CASE WHEN A.AgentState IN (SELECT AgentState FROM @BoldDisclamerStates) THEN 1 ELSE 0 END)
from agent A
where idagent=@IdAgent

--Select       
--		  '' CorporationPhone,      
--		  '' CorporationName,    
--		  '' ReceiptTransferEnglishMessage,
--		  '' ReceiptTransferSpanishMessage,  
--		  '' AgentName,      
--		  '' AgentAddress,      
--		  '' AgentLocation,      
--		  '' AgentPhone,		  
--          '' DisclaimerES01,
--          '' DisclaimerEn01,
--          '' DisclaimerES02,
--          '' DisclaimerEn02,
--          '' DisclaimerES03,
--          '' DisclaimerEn03,
--          '' DisclaimerES04,
--          '' DisclaimerEn04,
--          '' DisclaimerES05,
--          '' DisclaimerEn05,
--          '' DisclaimerES06,
--          '' DisclaimerEn06,
--          '' BranchName,
--          '' BranchLocation
--from agent A


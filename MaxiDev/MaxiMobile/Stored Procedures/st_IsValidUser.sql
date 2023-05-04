/********************************************************************
<Author> Mhinojo </Author>
<app> WebApi </app>
<Description> Sp para validar el user y pass de un usuario </Description>

<ChangeLog>
<log Date="05/06/2017" Author="Mhinojo">Creation</log>
</ChangeLog>

*********************************************************************/

CREATE PROCEDURE [MaxiMobile].[st_IsValidUser]
(
	@UserLogin nvarchar(500),
	@UserPass nvarchar(500)
)
AS
declare @lenguage1 int = 1
declare @lenguage2 int = 2
declare @ReceiptTransferCancelEnglishMessage varchar(max)      
declare @ReceiptTransferCancelSpanishMessage varchar(max)  
declare @CorporationPhone varchar(50)    
declare @CorporationName varchar(50)  
declare @ReceiptTransferEnglishMessage varchar(max)   
declare @ReceiptTransferSpanishMessage varchar(max)   
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
declare @BonusMessage  nvarchar(max)
declare @SendTextMessageEn nvarchar(max)
declare @SendTextMessageEs nvarchar(max)
declare @MaxiAgentMobileSupportURL nvarchar(max)
declare @CobranzaPhoneAgent nvarchar(max)
declare @CustomerServicePhoneAgent nvarchar(max)
declare @FullfillmentPhoneAgent nvarchar(max)
declare @SupportPhoneAgent nvarchar(max)

/*
	set @ReceiptTransferEnglishMessage =''
	set @ReceiptTransferSpanishMessage =''
	select 	 @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1Ca')
	select		@DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer1Ca')		
	select	   @DisclaimerES08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8CA')
	select     @DisclaimerEN08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer8CA')
*/

select 
@CorporationName = dbo.GetGlobalAttributeByName('CorporationName'),
@CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone'),
 @ReceiptTransferCancelEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferCancelMessage'),
       @ReceiptTransferCancelSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ReceiptTransferCancelMessage'),
       @ReceiptTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferMessage'),   
       @ReceiptTransferSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ReceiptTransferMessage'),
       @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1'),
       @DisclaimerEN02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer2'),
       @DisclaimerEN03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer3'),
       @DisclaimerEN04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer4'),
       @DisclaimerEN05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer5'),
       @DisclaimerEN06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer6'),
	   @DisclaimerEN07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer7'),
	   @DisclaimerEN08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer8'),
       @DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer1'),
       @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer2'),
       @DisclaimerES03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer3'),
       @DisclaimerES04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer4'),
       @DisclaimerES05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer5'),
       @DisclaimerES06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer6'),
	   @DisclaimerES07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer7'),
	   @DisclaimerES08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8'),
       @BonusMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'PMBonification'),
	   @SendTextMessageEn = [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'SendTextMessage'),
	   @SendTextMessageEs = [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'SendTextMessage'),
	   @MaxiAgentMobileSupportURL = [dbo].GetGlobalAttributeByName('MaxiAgentMobileSupportURL'),
	   @CobranzaPhoneAgent = [dbo].GetGlobalAttributeByName('CobranzaPhoneAgent'),
	   @CustomerServicePhoneAgent = [dbo].GetGlobalAttributeByName('CustomerServicePhoneAgent'),
	   @FullfillmentPhoneAgent = [dbo].GetGlobalAttributeByName('FullfillmentPhoneAgent'),
	   @SupportPhoneAgent = [dbo].GetGlobalAttributeByName('SupportPhoneAgent')
	   

SELECT        
U.DateOfCreation, U.IdUser, U.IdUserType, UT.Name AS NameUserType, U.UserLogin, U.UserName, U.UserPassword, AU.IdAgent,
CASE AU.IdAgent WHEN NULL THEN 1 ELSE 0 END AS IsMultiAgent, U.AllowToRegisterPc, 
U.ChangePasswordAtNextLogin, U.salt, A.AgentCode, A.AgentName,
A.AgentAddress,      
		  A.AgentCity+ ' '+ A.AgentState + ' '+ 
			REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS AgentLocation,
		  A.AgentPhone,   
		  a.AgentState,   
@CorporationPhone CorporationPhone,  
@CorporationName CorporationName,
@ReceiptTransferCancelEnglishMessage ReceiptTransferCancelEnglishMessage,
@ReceiptTransferCancelSpanishMessage ReceiptTransferCancelSpanishMessage,
 case when a.AgentState='CA' then '' else @ReceiptTransferEnglishMessage end ReceiptTransferEnglishMessage,
 case when a.AgentState='CA' then '' else @ReceiptTransferSpanishMessage end ReceiptTransferSpanishMessage,
 case when a.AgentState='CA' then [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer1Ca') else @DisclaimerES01 end DisclaimerES01,
 case when a.AgentState='CA' then [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1Ca') else @DisclaimerEn01 end DisclaimerEn01,
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
		  @DisclaimerES06 DisclaimerES07,
          @DisclaimerEn06 DisclaimerEn07,
  case when a.AgentState='CA' then [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8CA') else @DisclaimerES08 end DisclaimerEs08,
  case when a.AgentState='CA' then [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer8CA') else @DisclaimerEN08 end DisclaimerEn08,
		   @BonusMessage  BonusMessage	,
		   @SendTextMessageEn SendTextMessageEn,
		   @SendTextMessageEs	   SendTextMessageEs,
		   @MaxiAgentMobileSupportURL MaxiAgentMobileSupportURL,
		   @CobranzaPhoneAgent CobranzaPhoneAgent,
		   @CustomerServicePhoneAgent CustomerServicePhoneAgent,
		   @FullfillmentPhoneAgent FullfillmentPhoneAgent,
		   @SupportPhoneAgent SupportPhoneAgent,
		   isnull(o.cel,'') ownerCel,
		   isnull(o.Email,'') ownerEmail
FROM            
UsersType AS UT 
INNER JOIN Users AS U ON U.IdUserType = UT.IdUserType AND U.IdGenericStatus = 1 AND U.UserLogin = @userlogin AND U.UserPassword = dbo.fnCreatePasswordHash(@userpass, U.salt) 
INNER JOIN AgentUser AS AU ON U.IdUser = AU.IdUser 
INNER JOIN Agent AS A ON AU.IdAgent = A.IdAgent
left join Owner o on a.IdOwner=o.IdOwner






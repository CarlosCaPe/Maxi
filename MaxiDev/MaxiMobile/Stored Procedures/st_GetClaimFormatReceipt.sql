CREATE procedure [MaxiMobile].[st_GetClaimFormatReceipt]
(	@IdAgent int
) AS
/********************************************************************
<Author> ??? </Author>
<app> Agent, Corporative </app>
<Description> Gets print information for Tickets and Recepits</Description>

<ChangeLog>
<log Date="28/08/2017" Author="snevarez">Gets claims format text of Agent´s</log>
</ChangeLog>
*********************************************************************/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @InterCode NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('InfiniteCountryCode')

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
declare @lenguage1 int;
declare @lenguage2 int;

select @lenguage1=idlenguage 
    from countrylenguage 
	   where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryUSA'));

select @lenguage2=idlenguage 
    from countrylenguage 
	   where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryMexico'));

declare @ReceiptTransferEnglishMessage varchar(max)   
declare @ReceiptTransferSpanishMessage varchar(max)   

--ClaimFormat
declare @ClaimFormatEN00 nvarchar(max);
declare @ClaimFormatEN01 nvarchar(max);
declare @ClaimFormatEN02 nvarchar(max);
declare @ClaimFormatEN03 nvarchar(max);
declare @ClaimFormatEN04 nvarchar(max);
declare @ClaimFormatEN05 nvarchar(max);
declare @ClaimFormatEN06 nvarchar(max);
declare @ClaimFormatEN07 nvarchar(max);
declare @ClaimFormatEN08 nvarchar(max);
declare @ClaimFormatEN09 nvarchar(max);
declare @ClaimFormatEN10 nvarchar(max);

declare @ClaimFormatEN11 nvarchar(max);
declare @ClaimFormatEN12 nvarchar(max);
declare @ClaimFormatEN13 nvarchar(max);
declare @ClaimFormatEN14 nvarchar(max);
declare @ClaimFormatEN15 nvarchar(max);
declare @ClaimFormatEN16 nvarchar(max);
declare @ClaimFormatEN17 nvarchar(max);
declare @ClaimFormatEN18 nvarchar(max);
declare @ClaimFormatEN19 nvarchar(max);


declare @ClaimFormatES00 nvarchar(max);
declare @ClaimFormatES01 nvarchar(max);
declare @ClaimFormatES02 nvarchar(max);
declare @ClaimFormatES03 nvarchar(max);
declare @ClaimFormatES04 nvarchar(max);
declare @ClaimFormatES05 nvarchar(max);
declare @ClaimFormatES06 nvarchar(max);
declare @ClaimFormatES07 nvarchar(max);
declare @ClaimFormatES08 nvarchar(max);
declare @ClaimFormatES09 nvarchar(max);
declare @ClaimFormatES10 nvarchar(max);

declare @ClaimFormatES11 nvarchar(max);
declare @ClaimFormatES12 nvarchar(max);
declare @ClaimFormatES13 nvarchar(max);
declare @ClaimFormatES14 nvarchar(max);
declare @ClaimFormatES15 nvarchar(max);
declare @ClaimFormatES16 nvarchar(max);
declare @ClaimFormatES17 nvarchar(max);
declare @ClaimFormatES18 nvarchar(max);
declare @ClaimFormatES19 nvarchar(max);
declare @MobileClaimPDFEn nvarchar(max);
declare @MobileClaimPDFEs nvarchar(max);

-----mensajes
Select 
    @ReceiptTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferEnglishMessage'),   
    @ReceiptTransferSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ReceiptTransferSpanishMessage'),

    @ClaimFormatEN00=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat0'),
    @ClaimFormatEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat1'),
    @ClaimFormatEN02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat2'),
    @ClaimFormatEN03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat3'),
    @ClaimFormatEN04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat4'),
    @ClaimFormatEN05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat5'),
    @ClaimFormatEN06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat6'),
    @ClaimFormatEN07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat7'),
    @ClaimFormatEN08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat8'),
    @ClaimFormatEN09=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat9'),
    @ClaimFormatEN10=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat10'),

    @ClaimFormatEN11=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat11'),
    @ClaimFormatEN12=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat12'),
    @ClaimFormatEN13=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat13'),
    @ClaimFormatEN14=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat14'),
    @ClaimFormatEN15=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat15'),
    @ClaimFormatEN16=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat16'),
    @ClaimFormatEN17=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat17'),
    @ClaimFormatEN18=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat18'),
    @ClaimFormatEN19=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ClaimFormat19'),

    @ClaimFormatES00=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat0'),
    @ClaimFormatES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat1'),
    @ClaimFormatES02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat2'),
    @ClaimFormatES03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat3'),
    @ClaimFormatES04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat4'),
    @ClaimFormatES05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat5'),
    @ClaimFormatES06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat6'),
    @ClaimFormatES07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat7'),
    @ClaimFormatES08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat8'),
    @ClaimFormatES09=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat9'),
    @ClaimFormatES10=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat10'),

    @ClaimFormatES11=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat11'),
    @ClaimFormatES12=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat12'),
    @ClaimFormatES13=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat13'),
    @ClaimFormatES14=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat14'),
    @ClaimFormatES15=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat15'),
    @ClaimFormatES16=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat16'),
    @ClaimFormatES17=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat17'),
    @ClaimFormatES18=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat18'),
    @ClaimFormatES19=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ClaimFormat19'),
	@MobileClaimPDFEn =  dbo.GetGlobalAttributeByName('MobileClaimPDFEn'),
	@MobileClaimPDFEs =  dbo.GetGlobalAttributeByName('MobileClaimPDFEs')

Declare @Resend bit  
Set @Resend=1  

Declare @NotResend bit  
Set @NotResend=0  

Declare @ComprobanteMessage int 
set @ComprobanteMessage=0
 
If exists(Select 1 from Agent where IdAgent=@IdAgent)    
Begin

    Select       
	   A.IdAgent AS IdAgent,
	   A.AgentCode+' '+ A.AgentName AS AgentName,      
	   A.AgentAddress,      
	   A.AgentCity+ ' '+ A.AgentState + ' '+ REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS AgentLocation,
	   A.AgentPhone,     
		 
	   @ReceiptTransferEnglishMessage AS 'ReceiptTransferEnglishMessage',   
	   @ReceiptTransferSpanishMessage AS'ReceiptTransferSpanishMessage',
	   GETDATE() AS PrintDateTime,

	   @ClaimFormatEN00 AS 'ClaimFormatEn00',
	   @ClaimFormatEN01 AS 'ClaimFormatEn01',
	   @ClaimFormatEN02 AS 'ClaimFormatEn02',
	   @ClaimFormatEN03 AS 'ClaimFormatEn03',
	   @ClaimFormatEN04 AS 'ClaimFormatEn04',
	   @ClaimFormatEN05 AS 'ClaimFormatEn05',
	   @ClaimFormatEN06 AS 'ClaimFormatEn06',
	   @ClaimFormatEN07 AS 'ClaimFormatEn07',
	   @ClaimFormatEN08 AS 'ClaimFormatEn08',
	   @ClaimFormatEN09 AS 'ClaimFormatEn09',
	   @ClaimFormatEN10 AS 'ClaimFormatEn10',

	   @ClaimFormatEN11 AS 'ClaimFormatEn11',

	   @ClaimFormatEN12 AS 'ClaimFormatEn12',
	   @ClaimFormatEN13 AS 'ClaimFormatEn13',
	   @ClaimFormatEN14 AS 'ClaimFormatEn14',

	   @ClaimFormatEN15 AS 'ClaimFormatEn15',

	   @ClaimFormatEN16 AS 'ClaimFormatEn16',
	   @ClaimFormatEN17 AS 'ClaimFormatEn17',

	   @ClaimFormatEN18 AS 'ClaimFormatEn18',
	   @ClaimFormatEN19 AS 'ClaimFormatEn19',

	   report.HTML_JUSTIFY(@ClaimFormatEN06,165, 'Verdana', 9,0,0) AS 'EnHtml',
	   report.HTML_JUSTIFY((@ClaimFormatEN12 + ' ' + @ClaimFormatEN13 + ' ' + @ClaimFormatEN14),165, 'Verdana', 9,0,0) AS 'EnHtml00',
	   report.HTML_JUSTIFY((@ClaimFormatEN16 + ' ' + @ClaimFormatEN17) , 165, 'Verdana', 9,0,0) AS 'EnHtml01',
	   report.HTML_JUSTIFY((@ClaimFormatEN18 + ' ' + @ClaimFormatEN19) , 165, 'Verdana', 9,0,0) AS 'EnHtml02',

	   @ClaimFormatES00 AS 'ClaimFormatEs00',
	   @ClaimFormatES01 AS 'ClaimFormatEs01',
	   @ClaimFormatES02 AS 'ClaimFormatEs02',
	   @ClaimFormatES03 AS 'ClaimFormatEs03',
	   @ClaimFormatES04 AS 'ClaimFormatEs04',
	   @ClaimFormatES05 AS 'ClaimFormatEs05',
	   @ClaimFormatES06 AS 'ClaimFormatEs06',
	   @ClaimFormatES07 AS 'ClaimFormatEs07',
	   @ClaimFormatES08 AS 'ClaimFormatEs08',
	   @ClaimFormatES09 AS 'ClaimFormatEs09',
	   @ClaimFormatES10 AS 'ClaimFormatEs10',

	   @ClaimFormatES11 AS 'ClaimFormatEs11',

	   @ClaimFormatES12 AS 'ClaimFormatEs12',
	   @ClaimFormatES13 AS 'ClaimFormatEs13',
	   @ClaimFormatES14 AS 'ClaimFormatEs14',

	   @ClaimFormatES15 AS 'ClaimFormatEs15',

	   @ClaimFormatES16 AS 'ClaimFormatEs16',
	   @ClaimFormatES17 AS 'ClaimFormatEs17',

	   @ClaimFormatES18 AS 'ClaimFormatEs18',
	   @ClaimFormatES19 AS 'ClaimFormatEs19'

	   ,report.HTML_JUSTIFY(@ClaimFormatES06,165, 'Verdana', 9,0,0) AS 'EsHtml'
	   ,report.HTML_JUSTIFY((@ClaimFormatES12 + ' ' + @ClaimFormatES13 + ' ' + @ClaimFormatES14),165, 'Verdana', 9,0,0) AS 'EsHtml00'
	   ,report.HTML_JUSTIFY((@ClaimFormatES16 + ' ' + @ClaimFormatES17) , 165, 'Verdana', 9,0,0) AS 'EsHtml01'
	   ,report.HTML_JUSTIFY((@ClaimFormatES18 + ' ' + @ClaimFormatES19) , 165, 'Verdana', 9,0,0) AS 'EsHtml02'
	   ,@MobileClaimPDFEn as 'MobileClaimPDFEn'
	   ,@MobileClaimPDFEs as 'MobileClaimPDFEs'
    from Agent AS A WITH(NOLOCK)
	   where A.IdAgent = @IdAgent;
 
 End

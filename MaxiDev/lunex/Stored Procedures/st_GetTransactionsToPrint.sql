/********************************************************************
<Author>Azavala</Author>
<app>Maxi App</app>
<Description>Return a receipts for lunex </Description>

<ChangeLog>
<log Date="08/01/2016" Author="UNKNOWN"> Creación </log>
<log Date="08/08/2017" Author="Mhinojo"> Alter </log>
<log Date="18/06/2017" Author="Azavala"> Creation </log>
<log Date="19/06/2017" Author="snevarez"> Se agrego IdUser</log>
<log Date="17/06/2020" Author="jgomez">Modificación de Disclamers.se agrego with(nolock) en las consultas:: Ref: M00177-Lunex</log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [Lunex].[st_GetTransactionsToPrint] 
	@IdAgent int
	,@IdUser int
AS
BEGIN try
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	--set @IdUser=2162
	--declare @IdAgent int
	--set @IdAgent=1242
	--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('GetTransactionsToPrint',Getdate(),''+CONVERT(varchar(10),@IdAgent)+'; IdUser: '+CONVERT(varchar(10),@IdUser))
	IF OBJECT_ID('tempdb..#LunexTmp') IS NOT NULL
		begin
			Drop table #LunexTmp
		end

	declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');   
  
declare @ReceiptPureMinutesEnglishMessage varchar(max)      
set @ReceiptPureMinutesEnglishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesEnglishMessage');   

declare @ReceiptPureMinutesSpanishMessage varchar(max)      
set @ReceiptPureMinutesSpanishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesSpanishMessage');   

declare  @AgentState varchar(10)
set @AgentState = (Select AgentState from Agent with(nolock) where IdAgent=@IdAgent)
--get lenguage resource
declare @lenguage1 int
declare @lenguage2 int

select @lenguage1=idlenguage from countrylenguage where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryUSA'))
select @lenguage2=idlenguage from countrylenguage where idcountry=convert(int,[dbo].[GetGlobalAttributeByName]('IdCountryMexico'))

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

declare @DisclaimerEN01 nvarchar(max)
declare @DisclaimerEN02 nvarchar(max)
declare @DisclaimerEN03 nvarchar(max)
declare @DisclaimerEN04 nvarchar(max)
declare @DisclaimerEN05 nvarchar(max)
declare @DisclaimerEN06 nvarchar(max)
declare @DisclaimerEN07 nvarchar(max)

declare @DisclaimerEN08 nvarchar(max)
declare @EmphasizedDisclamer bit


DECLARE @AffiliationNoticeEnglish AS NVARCHAR(MAX) 
DECLARE @AffiliationNoticeSpanish AS NVARCHAR(MAX) 
declare @DisclaimerFederalEN nvarchar(max)
declare @Disclaimer13EN nvarchar(max)
DECLARE @ComplaintNoticeEnglish AS NVARCHAR(MAX) 
DECLARE @ComplaintNoticeSpanish AS NVARCHAR(MAX) 
declare @DisclaimerFederalES nvarchar(max)
declare @Disclaimer13ES nvarchar(max) = ''


SELECT 
@AffiliationNoticeEnglish = ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),''), 
@ComplaintNoticeEnglish = ComplaintNoticeEnglish, 
@AffiliationNoticeSpanish = ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),''), 
@ComplaintNoticeSpanish = ComplaintNoticeSpanish 
FROM Agent A with(nolock)
INNER JOIN  [State] S with(nolock) ON S.StateCode = A.AgentState 
INNER JOIN StateNote SN with(nolock) ON SN.IdState = S.IdState 
WHERE IdAgent = @IdAgent



select @ReceiptTransferEnglishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'ReceiptTransferMessage'),   
       @ReceiptTransferSpanishMessage=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'ReceiptTransferMessage'),
       @DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill01'), --M00183 - RECIBO DE MEGA (TICKET 2087)
       @DisclaimerEN02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill02'), --M00183 - RECIBO DE MEGA (TICKET 2087)
       @DisclaimerEN03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill03'), --M00183 - RECIBO DE MEGA (TICKET 2087)
       @DisclaimerEN04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill04'), --M00183 - RECIBO DE MEGA (TICKET 2087)
       @DisclaimerEN05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill05'),  --M00183 - RECIBO DE MEGA (TICKET 2087)
       --@DisclaimerEN06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer6'), --M00183 - RECIBO DE MEGA (TICKET 2087)
	   --@DisclaimerEN07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer7'), --M00183 - RECIBO DE MEGA (TICKET 2087)

	   --@DisclaimerEN08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer8'), --M00183 - RECIBO DE MEGA (TICKET 2087)
	 
       @DisclaimerES01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill01'), --M00183 - RECIBO DE MEGA (TICKET 2087)
       @DisclaimerES02=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill02'), --M00183 - RECIBO DE MEGA (TICKET 2087)
       @DisclaimerES03=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill03'), --M00183 - RECIBO DE MEGA (TICKET 2087)
       @DisclaimerES04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill04'), --M00183 - RECIBO DE MEGA (TICKET 2087)
       @DisclaimerES05=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill05'), --END M00183 - RECIBO DE MEGA (TICKET 2087)
       --@DisclaimerES06=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer6'), --M00183 - RECIBO DE MEGA (TICKET 2087)
	   --@DisclaimerES07=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer7'), --M00183 - RECIBO DE MEGA (TICKET 2087)

	   --@DisclaimerES08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8'),  --M00183 - RECIBO DE MEGA (TICKET 2087)
	   @DisclaimerFederalEN=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerFederalEN'),
	   @DisclaimerFederalES= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerFederalES') 

SET @EmphasizedDisclamer = 0
IF (@AgentState = 'CA')
BEGIN
    select @DisclaimerEN04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'DisclaimerBill04CA') --M00183 - RECIBO DE MEGA (TICKET 2087)
	select @DisclaimerES04=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'DisclaimerBill04CA') --M00183 - RECIBO DE MEGA (TICKET 2087)
	/*SET @AffiliationNoticeEnglish = ''
	SET @AffiliationNoticeSpanish = ''
	SET @EmphasizedDisclamer = 1
	set @ReceiptTransferEnglishMessage =''
	set @ReceiptTransferSpanishMessage =''
	select 	@DisclaimerEN01=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1Ca')
	select	@DisclaimerES01= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer1Ca') 
	select	@DisclaimerES08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8CA')
	select  @DisclaimerEN08=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer8CA')
	select	@DisclaimerES04= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer4') 
	select	@DisclaimerES05= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer5') 
	select	@DisclaimerES06= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer6') 
	select	@DisclaimerES08= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8CA') 
	select	@Disclaimer13EN=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer13ENCa')
	select	@Disclaimer13ES= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer13ESCa') 
	SET @DisclaimerEN07 = ''
	SET @DisclaimerES07 = '' **/ --M00183 - RECIBO DE MEGA (TICKET 2087)
END
/*IF (@AgentState = 'CO')
BEGIN
	SELECT @DisclaimerEN01= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1Co') 
	SELECT @DisclaimerEN08= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer8Ca') 
	SELECT @DisclaimerES04= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer4') 
	SELECT @DisclaimerES05= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer5') 
	SELECT @DisclaimerES06= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer6') 
	SELECT @DisclaimerES08= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer8') 
	SELECT @DisclaimerES02= [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer2') 
	--SELECT @DisclaimerES03= CASE WHEN @lenguage2 = 3 THEN [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer10') ELSE [dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer3') END
END */ --M00183 - RECIBO DE MEGA (TICKET 2087)
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
       @DisclaimerEN01Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer1'),
       @DisclaimerEN02Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer2'),
       @DisclaimerEN03Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer3'),
	   @DisclaimerEN07Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage1,'Disclaimer7'),

       @DisclaimerES01Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer1'),
       @DisclaimerES02Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer2'),
       @DisclaimerES03Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer3'),
	   @DisclaimerES07Pre=[dbo].[GetMessageFromMultiLenguajeResorces](@lenguage2,'Disclaimer7')

Select   top 1
	  piv.IdTransferLN,
      @CorporationPhone CorporationPhone,      
      @CorporationName CorporationName,     
      @ReceiptPureMinutesEnglishMessage ReceiptEnglishMessage,
      @ReceiptPureMinutesSpanishMessage ReceiptSpanishMessage,  
      ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
      A.AgentAddress,      
      ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ 
	    REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS  AgentLocation,      
      A.AgentPhone,
      t.IdProductTransfer,
      t.TransactionProviderID IdTransaction,
      t.TransactionProviderDate DateOfTransaction,  
      piv.TopupPhone Phonenumber,
      t.Amount Amount,  
      t.TransactionProviderID Reference,
      null CountryName,
      piv.SKUName CarrierName,        
      'USD' LocalCurrency,
      null pinBased,
      null pinValidity,
      null pinCode,
      null pinIvr,
      null pinSerial,
      piv.pin pinValue,
      null pinOption1,
      null pinOption2,
      null pinOption3,
      piv.[key] [Key],  
      piv.ReceivedValue LocalInfoValue,
      piv.ReceivedValue LocalAmountReceived    
        , A.AgentFax	
	    , A.AgentName AS AgentNameTicket
	    , A.AgentCode
	    , A.AgentZipcode
	    , A.AgentState
	    , A.AgentCity
        ,t.EnterByIdUser
        ,u.UserLogin UserName
        ,t.EnterByIdUserCancel
        ,t.TransactionProviderCancelDate DateOfCancelTransaction
        ,isnull(u2.UserLogin,'') UserNameCancel
		,ISNULL(t.Fee, 0) AS Fee,
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
		  /**@DisclaimerES06 DisclaimerES06,
          @DisclaimerEn06 DisclaimerEn06,
		  @DisclaimerES08 DisclaimerEs08,
          @DisclaimerEN08 DisclaimerEn08, */ --M00183 - RECIBO DE MEGA (TICKET 2087)
		  '*** ' + @DisclaimerEN07 + '.' DisclaimerEn07,
		  '*** ' + @DisclaimerEs07 + '.' DisclaimerEs07,
		  @EmphasizedDisclamer as EmphasizedDisclamer,
		  '' CustomerFullName,
		  @AffiliationNoticeEnglish AffiliationNoticeEnglish,
		  @AffiliationNoticeSpanish AffiliationNoticeSpanish,
		  @DisclaimerFederalEN DisclaimerFederalEN, 
			@Disclaimer13EN Disclaimer13EN,
		@ComplaintNoticeEnglish ComplaintNoticeEnglish,
		@ComplaintNoticeSpanish ComplaintNoticeSpanish,
		@DisclaimerFederalES DisclaimerFederalES,
		@Disclaimer13ES Disclaimer13ES,
		@ReceiptTransferEnglishMessage ReceiptTransferEnglishMessage,
		@ReceiptTransferSpanishMessage ReceiptTransferSpanishMessage,
		'I attest to have received $'+ CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' from the customer/reconozco haber recibido $'
		  + CONVERT(NVARCHAR(MAX),ROUND((T.Amount+T.Fee),2)) + ' del cliente' AttestMessage
		,0 Tax
		,Case A.AgentState When 'OK' Then 'Oklahoma' When NULL Then case when a.agentstate='OK' Then 'Oklahoma' when a.agentstate!='OK' Then a.agentstate else ''END Else  AgentState End StateTax,
				  @DisclaimerES01Pre DisclaimerES01Pre,
		@DisclaimerES02Pre DisclaimerES02Pre,
		@DisclaimerES03Pre DisclaimerES03Pre,
		@DisclaimerES07Pre DisclaimerES07Pre,
		@DisclaimerEN01Pre DisclaimerEN01Pre,
		@DisclaimerEN02Pre DisclaimerEN02Pre,
		@DisclaimerEN03Pre DisclaimerEN03Pre,
		@DisclaimerEN07Pre DisclaimerEN07Pre,
		piv.DateOfPrint,
		piv.AmountInMN,
		piv.ExRate,
		piv.CountryCurrency
	into #LunexTmp
    from [Operation].[ProductTransfer] t with(nolock)
	    inner join Agent a with(nolock) on a.IdAgent= t.IdAgent   
        join users u with(nolock) on t.EnterByIdUser=u.iduser        
        left join users u2 with(nolock) on t.EnterByIdUserCancel=u2.iduser     
        join lunex.TransferLN piv with(nolock) on piv.IdProductTransfer=t.IdProductTransfer
    where t.IdOtherProduct = 9 and piv.WasPrint=0 and piv.IdStatus=30 and piv.IdAgent=@IdAgent
	   and piv.EnterByIdUser = @IdUser /*19/06/2017*/

	update T1 set T1.WasPrint=1, T1.DateOfPrint=GETDATE() from Lunex.TransferLN T1 with(nolock) inner join #LunexTmp T2 on T1.IdTransferLN=T2.IdTransferLN
	
	select * from #LunexTmp
END try
BEGIN CATCH
	declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('GetTransactionsToPrint',Getdate(),@ErrorMessage)
END CATCH

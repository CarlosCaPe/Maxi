
  
CREATE procedure [dbo].[st_LoadXMLWithFileName]         
	@fileName nvarchar(max)
as        
Set nocount on       
      
Truncate Table Softgate.TBillers      
        
------------- Load XLM --------------------------------------------------------------        
DECLARE @idoc INT, @d VARCHAR(MAX)        
      
 declare @query varchar(200)      
 --declare @fileName varchar(100)      
 declare @tempDoc table( d varchar(max))       
 --set @fileName =dbo.GetGlobalAttributeByName('FilePathSoftgateProducts')      
 set @query ='SELECT * FROM OPENROWSET(BULK '''+@fileName+''', SINGLE_BLOB) AS X  '       
 insert into @tempDoc exec (@query)       
 set @d = (select top 1 d from @tempDoc)       
       
      
------------------------------------------------------------------------------------       

EXEC sp_xml_preparedocument @idoc OUTPUT, @d        
Insert into softgate.TBillers        
(        
VendorID,        
TerminalNumber,        
VendorType,        
VendorSubType,
VendorPostType,        
VendorFeeClass,        
VendorRemitCountry,        
VendorName,        
VendorMasterName,        
VendorDetailDesc,        
EntryMaskFlag,        
VendorAccountLengthMin,        
VendorAccountLengthMax,        
VendorTranAmtMin,        
VendorTranAmtMax,        
DuplicateEntryFlag,        
CustFee,        
CustMinFee,        
CustMaxFee,        
IPPFeeShare,        
CustNameRequired,        
SenderNameRequired,        
SenderRequiredAmtMin,        
MaskAcctOnReceipt,        
VendorFavoriteSeq,        
PostingTimeDesc,        
PostingTimeCutoff,        
VendorRemitTiming,        
PresentmentFlag,        
FormFlag,        
FormDetails,        
VendorServiceArea,        
BillerHelpFlag,        
BillerHelp         
)        
SELECT         
VendorID,        
TerminalNumber,        
VendorType,        
VendorSubType,
VendorPostType,        
VendorFeeClass,        
VendorRemitCountry,        
VendorName,        
VendorMasterName,        
VendorDetailDesc,        
EntryMaskFlag,        
VendorAccountLengthMin,        
VendorAccountLengthMax,        
VendorTranAmtMin,        
VendorTranAmtMax,        
DuplicateEntryFlag,        
CustFee,        
CustMinFee,        
CustMaxFee,        
IPPFeeShare,        
CustNameRequired,        
SenderNameRequired,        
SenderRequiredAmtMin,        
MaskAcctOnReceipt,        
VendorFavoriteSeq,        
PostingTimeDesc,        
PostingTimeCutoff,        
VendorRemitTiming,        
PresentmentFlag,        
FormFlag,        
FormDetails,        
VendorServiceArea,        
BillerHelpFlag,        
BillerHelp         
FROM OPENXML (@idoc, 'BillerLoad/MerchID/Detail',2)          
WITH (        
TerminalNumber int,        
VendorID varchar(max),        
VendorType varchar(max),        
VendorSubType varchar(max),        
VendorPostType varchar(max),
VendorFeeClass varchar(max),        
VendorRemitCountry varchar(max),        
VendorName varchar(max),        
VendorMasterName varchar(max),        
VendorDetailDesc varchar(max),        
EntryMaskFlag varchar(max),        
VendorAccountLengthMin smallint,        
VendorAccountLengthMax smallint,        
VendorTranAmtMin Money,        
VendorTranAmtMax Money,        
DuplicateEntryFlag varchar(max),        
CustFee money,        
CustMinFee Money,        
CustMaxFee money,        
IPPFeeShare money,        
CustNameRequired char(1),        
SenderNameRequired char(1),        
SenderRequiredAmtMin char(1),        
MaskAcctOnReceipt char(1),        
VendorFavoriteSeq smallint,        
PostingTimeDesc varchar(max),        
PostingTimeCutoff varchar(max),        
VendorRemitTiming varchar(max),        
PresentmentFlag CHAR(1),        
FormFlag CHAR(1),        
FormDetails xml,        
VendorServiceArea xml,        
BillerHelpFlag CHAR(1),        
BillerHelp xml        
)                             
EXEC sp_xml_removedocument @idoc             
        
----------------------- Load FormDetails    ------------------------------------------------------------------------        
        
Select IdTBillers into #temp1 from softgate.TBillers where Formdetails is not null      
Declare @FormDetail xml,@IdBill int        
        
Declare @AcctNumOptional nvarchar(max),        
@AltLookupLabel nvarchar(max),        
@AltLookupVisibleLen nvarchar(max),        
@AltLookupMaxLen nvarchar(max),        
@AddInfoLabel1 nvarchar(max),        
@AddInfoReqFlag1 nvarchar(max),        
@AddInfoValType1 nvarchar(max),        
@AddInfoVisibleLen1 nvarchar(max),        
@AddInfoMaxLen1 nvarchar(max),        
@AddInfoLabel2 nvarchar(max),        
@AddInfoReqFlag2 nvarchar(max),        
@AddInfoValType2 nvarchar(max),        
@AddInfoVisibleLen2 nvarchar(max),        
@AddInfoMaxLen2 nvarchar(max),        
@DispOnlyLabel1 nvarchar(max),        
@DispOnlyLen1 nvarchar(max),        
@DispOnlyLabel2 nvarchar(max),        
@DispOnlyLen2 nvarchar(max),       
@PrevBalDispFlag nvarchar(max),        
@PrevPaidDispFlag nvarchar(max),        
@LatestBillDispFlag nvarchar(max),        
@BalDueDispFlag nvarchar(max),        
@DueDateDispFlag nvarchar(max)        
        
        
While Exists(Select 1 from #temp1)        
Begin         
Select top 1 @IdBill=IdTBillers from #temp1        
Select  @FormDetail=Formdetails from softgate.TBillers where IdTBillers=@IdBill         
        
EXEC sp_xml_preparedocument @idoc OUTPUT, @FormDetail        
        
SELECT        
@AcctNumOptional=AcctNumOptional,         
@AltLookupLabel=AltLookupLabel,        
@AltLookupVisibleLen=AltLookupVisibleLen,        
@AltLookupMaxLen=AltLookupMaxLen,        
@AddInfoLabel1=AddInfoLabel1,        
@AddInfoReqFlag1=AddInfoReqFlag1,        
@AddInfoValType1=AddInfoValType1,        
@AddInfoVisibleLen1=AddInfoVisibleLen1,        
@AddInfoMaxLen1=AddInfoMaxLen1,        
@AddInfoLabel2=AddInfoLabel2,        
@AddInfoReqFlag2=AddInfoReqFlag2,        
@AddInfoValType2=AddInfoValType2,        
@AddInfoVisibleLen2=AddInfoVisibleLen2,        
@AddInfoMaxLen2=AddInfoMaxLen2,        
@DispOnlyLabel1=DispOnlyLabel1,        
@DispOnlyLen1=DispOnlyLen1,        
@DispOnlyLabel2=DispOnlyLabel2,        
@DispOnlyLen2=DispOnlyLen2,        
@PrevBalDispFlag=PrevBalDispFlag,        
@PrevPaidDispFlag=PrevPaidDispFlag,        
@LatestBillDispFlag=LatestBillDispFlag,        
@BalDueDispFlag=BalDueDispFlag,        
@DueDateDispFlag=DueDateDispFlag        
FROM OPENXML (@idoc, 'FormDetails',2) WITH         
(        
AcctNumOptional varchar(max),        
AltLookupLabel varchar(max),        
AltLookupVisibleLen varchar(max),        
AltLookupMaxLen varchar(max),        
AddInfoLabel1 varchar(max),        
AddInfoReqFlag1 varchar(max),        
AddInfoValType1 varchar(max),        
AddInfoVisibleLen1 varchar(max),        
AddInfoMaxLen1 varchar(max),        
AddInfoLabel2 varchar(max),        
AddInfoReqFlag2 varchar(max),        
AddInfoValType2 varchar(max),        
AddInfoVisibleLen2 varchar(max),        
AddInfoMaxLen2 varchar(max),        
DispOnlyLabel1 varchar(max),        
DispOnlyLen1 varchar(max),        
DispOnlyLabel2 varchar(max),        
DispOnlyLen2 varchar(max),        
PrevBalDispFlag varchar(max),        
PrevPaidDispFlag varchar(max),        
LatestBillDispFlag varchar(max),        
BalDueDispFlag varchar(max),        
DueDateDispFlag varchar(max)        
)          
EXEC sp_xml_removedocument @idoc             
        
Update softgate.TBillers set         
FormDetails_AcctNumOptional=@AcctNumOptional,        
FormDetails_AltLookupLabel=@AltLookupLabel,        
FormDetails_AltLookupVisibleLen=@AltLookupVisibleLen,        
FormDetails_AltLookupMaxLen=@AltLookupMaxLen,        
FormDetails_AddInfoLabel1=@AddInfoLabel1,        
FormDetails_AddInfoReqFlag1=@AddInfoReqFlag1,        
FormDetails_AddInfoValType1=@AddInfoValType1,        
FormDetails_AddInfoVisibleLen1=@AddInfoVisibleLen1,        
FormDetails_AddInfoMaxLen1=@AddInfoMaxLen1,        
FormDetails_AddInfoLabel2=@AddInfoLabel2,        
FormDetails_AddInfoReqFlag2=@AddInfoReqFlag2,        
FormDetails_AddInfoValType2=@AddInfoValType2,        
FormDetails_AddInfoVisibleLen2=@AddInfoVisibleLen2,        
FormDetails_AddInfoMaxLen2=@AddInfoMaxLen2,        
FormDetails_DispOnlyLabel1=@DispOnlyLabel1,        
FormDetails_DispOnlyLen1=@DispOnlyLen1,        
FormDetails_DispOnlyLabel2=@DispOnlyLabel2,        
FormDetails_DispOnlyLen2=@DispOnlyLen2,        
FormDetails_PrevBalDispFlag=@PrevBalDispFlag,        
FormDetails_PrevPaidDispFlag=@PrevPaidDispFlag,        
FormDetails_LatestBillDispFlag=@LatestBillDispFlag,        
FormDetails_BalDueDispFlag=@BalDueDispFlag,        
FormDetails_DueDateDispFlag=@DueDateDispFlag        
where IdTBillers=@IdBill        
        
Delete #temp1 where IdTBillers=@IdBill        
End        
        
------------------------------- Load Area --------------------------------------------------------        
 /*        
Select IdTBillers into #temp2 from softgate.TBillers where VendorServiceArea is not null        
Declare @VendorServiceArea xml        
        
        
While Exists(Select 1 from #temp2)        
Begin         
Select top 1 @IdBill=IdTBillers from #temp2        
Select  @VendorServiceArea=VendorServiceArea from softgate.TBillers where IdTBillers=@IdBill         
        
EXEC sp_xml_preparedocument @idoc OUTPUT, @VendorServiceArea        
Insert into Softgate.TArea (IdBiller,Description)        
SELECT        
@IdBill,        
Area as Description        
FROM OPENXML (@idoc, 'VendorServiceArea',2) WITH         
(        
Area varchar(max)        
)          
EXEC sp_xml_removedocument @idoc             
Delete #temp2 where IdTBillers=@IdBill        
End        
        
*/        
----------------------- Load Biller Help   ------------------------------------------------------------------------        
        
Select IdTBillers into #temp3 from softgate.TBillers where BillerHelp is not null       
Declare @BillerHelp xml        
        
Declare @HelpTextEnglish nvarchar(max),        
@HelpTextSpanish nvarchar(max),        
@HelpURL nvarchar(max)        
        
While Exists(Select 1 from #temp3)        
Begin         
Select top 1 @IdBill=IdTBillers from #temp3        
Select  @BillerHelp=BillerHelp from softgate.TBillers where IdTBillers=@IdBill         
        
EXEC sp_xml_preparedocument @idoc OUTPUT, @BillerHelp        
        
SELECT        
@HelpTextEnglish=HelpTextEnglish,         
@HelpTextSpanish=HelpTextSpanish,        
@HelpURL=HelpURL        
FROM OPENXML (@idoc, 'BillerHelp',2) WITH         
(        
HelpTextEnglish varchar(max),        
HelpTextSpanish varchar(max),        
HelpURL varchar(max)        
)          
EXEC sp_xml_removedocument @idoc             
        
Update softgate.TBillers set         
BillerHelpInfo_HelpTextEnglish=@HelpTextEnglish,        
BillerHelpInfo_HelpTextSpanish=@HelpTextSpanish,        
BillerHelpInfo_HelpURL=@HelpURL        
where IdTBillers=@IdBill        
        
Delete #temp3 where IdTBillers=@IdBill        
End        

print 'st_FillBillers'
        
exec st_FillBillers    

print 'st_ProductsByProviderUpdater'

exec st_ProductsByProviderUpdater    

print 'LogSoftgateLoadXML'

Insert into  [MAXILOG].[dbo].LogSoftgateLoadXML values (GETDATE())  
        
return 0
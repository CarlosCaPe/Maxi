
  
  
CREATE procedure st_FillBillers  
as  
Set nocount on   
Truncate Table Softgate.Billers    
    
Insert into Softgate.Billers    
(    
IdTBillers,    
TerminalNumber,    
VendorID,    
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
VendorDeployType,    
ScanImageFlag,    
ScanDataFlag,    
ScanDetails_Id,    
ScanDetails_CoordFieldType,    
ScanDetails_Coordinates,    
ScanDetails_OcrType,    
ScanLineFlag,    
SplitTenderFlag,    
SplitTenderDetails_AccChecksType,    
SplitTenderDetails_MultiAcccounts,    
PresentmentFlag,    
FormFlag,    
FormDetails_AcctNumOptional,    
FormDetails_AltLookupLabel,    
FormDetails_AltLookupVisibleLen,    
FormDetails_AltLookupMaxLen,    
FormDetails_AddInfoLabel1,    
FormDetails_AddInfoReqFlag1,    
FormDetails_AddInfoValType1,    
FormDetails_AddInfoVisibleLen1,    
FormDetails_AddInfoMaxLen1,    
FormDetails_AddInfoLabel2,    
FormDetails_AddInfoReqFlag2,    
FormDetails_AddInfoValType2,    
FormDetails_AddInfoVisibleLen2,    
FormDetails_AddInfoMaxLen2,    
FormDetails_DispOnlyLabel1,    
FormDetails_DispOnlyLen1,    
FormDetails_DispOnlyLabel2,    
FormDetails_DispOnlyLen2,    
FormDetails_PrevBalDispFlag,    
FormDetails_PrevPaidDispFlag,    
FormDetails_LatestBillDispFlag,    
FormDetails_BalDueDispFlag,    
FormDetails_DueDateDispFlag,    
BillerHelpFlag,    
BillerHelpInfo_HelpTextEnglish,    
BillerHelpInfo_HelpTextSpanish,    
BillerHelpInfo_HelpURL    
)    
Select     
IdTBillers,    
TerminalNumber,    
VendorID,    
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
Case when DuplicateEntryFlag='Y' Then 1     
  when DuplicateEntryFlag='N' Then 0    
  Else 0 End as DuplicateEntryFlag,    
CustFee,    
CustMinFee,    
CustMaxFee,    
IPPFeeShare,    
Case when CustNameRequired='N' Then 0     
  when CustNameRequired='O' Then 0    
  when CustNameRequired='R' Then 1    
  Else 0 End as CustNameRequired,    
Case when SenderNameRequired='Y' Then 1     
  when SenderNameRequired='N' Then 0    
  Else 0 End as SenderNameRequired,    
Convert(money,SenderRequiredAmtMin) as SenderRequiredAmtMin,    
Case when MaskAcctOnReceipt='Y' Then 1     
  when MaskAcctOnReceipt='N' Then 0    
  Else 0 End as MaskAcctOnReceipt,    
VendorFavoriteSeq,    
PostingTimeDesc,    
PostingTimeCutoff,    
VendorRemitTiming,    
VendorDeployType,    
ScanImageFlag,    
ScanDataFlag,    
ScanDetails_Id,    
ScanDetails_CoordFieldType,    
ScanDetails_Coordinates,    
ScanDetails_OcrType,    
ScanLineFlag,    
SplitTenderFlag,    
isNull(SplitTenderDetails_AccChecksType,0) as SplitTenderDetails_AccChecksType,    
isNull(SplitTenderDetails_MultiAcccounts,0) as SplitTenderDetails_MultiAcccounts,    
Case when PresentmentFlag='Y' Then 1     
  when PresentmentFlag='N' Then 0    
  Else 0 End as PresentmentFlag,    
Case when FormFlag='Y' Then 1     
  when FormFlag='N' Then 0    
  Else 0 End as FormFlag,    
Case when FormDetails_AcctNumOptional='Y' Then 1     
  when FormDetails_AcctNumOptional='N' Then 0    
  Else 0 End as FormDetails_AcctNumOptional,    
FormDetails_AltLookupLabel,    
convert(int,isnull(FormDetails_AltLookupVisibleLen,0)) as FormDetails_AltLookupVisibleLen,    
convert(int,isnull(FormDetails_AltLookupMaxLen,0)) as FormDetails_AltLookupMaxLen,    
FormDetails_AddInfoLabel1,    
Case when FormDetails_AddInfoReqFlag1='Y' Then 1     
  when FormDetails_AddInfoReqFlag1='N' Then 0    
  when FormDetails_AddInfoReqFlag1='C' Then 1    
  Else 0 End as FormDetails_AddInfoReqFlag1,    
FormDetails_AddInfoValType1,    
convert(int,isnull(FormDetails_AddInfoVisibleLen1,0)) as FormDetails_AddInfoVisibleLen1,    
convert(int,isnull(FormDetails_AddInfoMaxLen1,0)) as FormDetails_AddInfoMaxLen1,    
FormDetails_AddInfoLabel2,    
Case when FormDetails_AddInfoReqFlag2='Y' Then 1     
  when FormDetails_AddInfoReqFlag2='N' Then 0    
  when FormDetails_AddInfoReqFlag2='C' Then 1    
  Else 0 End as FormDetails_AddInfoReqFlag2,    
FormDetails_AddInfoValType2,     
convert(int,isnull(FormDetails_AddInfoVisibleLen2,0)) as FormDetails_AddInfoVisibleLen2,    
convert(int,isnull(FormDetails_AddInfoMaxLen2,0)) as FormDetails_AddInfoMaxLen2,    
FormDetails_DispOnlyLabel1,    
FormDetails_DispOnlyLen1,    
FormDetails_DispOnlyLabel2,    
FormDetails_DispOnlyLen2,    
FormDetails_PrevBalDispFlag,    
FormDetails_PrevPaidDispFlag,    
FormDetails_LatestBillDispFlag,    
FormDetails_BalDueDispFlag,    
FormDetails_DueDateDispFlag,    
Case when BillerHelpFlag='Y' Then 1     
  when BillerHelpFlag='N' Then 0    
  Else 0 End as BillerHelpFlag,    
BillerHelpInfo_HelpTextEnglish,    
BillerHelpInfo_HelpTextSpanish,    
BillerHelpInfo_HelpURL    
from Softgate.[TBillers]    
  

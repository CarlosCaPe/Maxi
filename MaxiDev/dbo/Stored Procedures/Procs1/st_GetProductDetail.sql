
 
CREATE procedure [dbo].[st_GetProductDetail]                
(                
@IdAgent int,                
@IdProductsByProvider int                
)                
as                
Set nocount on                 
Declare @AgentState varchar(max),@VendorName varchar(max),@GroupId int,@Enabled bit                
Declare @True bit,@False bit  
Set @True=1  
Set @False=0  
  
Select  @AgentState=AgentState from Agent where IdAgent=@IdAgent                
Select          
@Enabled=case when IdGenericStatus=1 then 1        
     when IdGenericStatus=2 then 0        
       Else 0 End,              
@GroupId=IdGroup,@VendorName=VendorID from productsbyprovider where IdProductsByProvider=@IdProductsByProvider              
                
Select              
@IdProductsByProvider as IdProductsByProvider,               
@GroupId as IdGroup,              
@Enabled  As Enabled,              
A.TerminalNumber as MerchID,              
A.VendorID,              
isnull(A.VendorType,'') as VendorType,              
isnull(A.VendorSubType,'') as VendorSubType,              
isnull(A.VendorPostType,'') as VendorPostType,              
isnull(A.VendorRemitCountry,'') as VendorRemitCountry,              
isnull(A.VendorName,'') as VendorName,               
isnull(A.VendorMasterName,'') as VendorMasterName,               
isnull(A.VendorDetailDesc,'') as VendorDetailDesc,            
isnull(A.EntryMaskFlag,'') as EntryMaskFlag,              
isnull(A.VendorAccountLengthMin,0) as VendorAccountLengthMin,              
isnull(A.VendorAccountLengthMax,0) as VendorAccountLengthMax,              
isnull(A.VendorTranAmtMin,0) as VendorTranAmtMin,              
isnull(A.VendorTranAmtMax,0) as VendorTranAmtMax,              
isnull(A.DuplicateEntryFlag,0) as DuplicateEntryFlag,               
isnull(A.CustFee,'') as CustFee,              
isnull(A.CustMinFee,'') as  CustMinFee,             
isnull(A.CustMaxFee,'') as  CustMaxFee,             
isnull(A.IPPFeeShare,'') as IPPFeeShare,              
isnull(A.CustNameRequired,'') as CustNameRequired,              
isnull(A.SenderNameRequired,'') as SenderNameRequired,              
isnull(A.SenderRequiredAmtMin,'') as SenderRequiredAmtMin,              
isnull(A.MaskAcctOnReceipt,'') as  MaskAcctOnReceipt,             
isnull(A.VendorFavoriteSeq,'') as VendorFavoriteSeq,              
isnull(A.PostingTimeDesc,'') as PostingTimeDesc,              
isnull(A.PostingTimeCutoff,'') as PostingTimeCutoff,              
isnull(A.VendorRemitTiming,'') as VendorRemitTiming,            
isnull(A.VendorDeployType,'') as VendorDeployType,              
isnull(A.ScanImageFlag,'') as ScanImageFlag,              
isnull(A.ScanDataFlag,'') as ScanDataFlag,              
isnull(A.ScanDetails_Id,'') as ScanDetails_Id,              
isnull(A.ScanDetails_CoordFieldType,'') as ScanDetails_CoordFieldType,              
isnull(A.ScanDetails_Coordinates,'') as ScanDetails_Coordinates,              
isnull(A.ScanDetails_OcrType,'') as ScanDetails_OcrType,              
isnull(A.ScanLineFlag,'') as ScanLineFlag,               
isnull(A.SplitTenderFlag,'') as SplitTenderFlag,              
isnull(A.SplitTenderDetails_AccChecksType,0) as SplitTenderDetails_AccChecksType,              
isnull(A.SplitTenderDetails_MultiAcccounts,0) as SplitTenderDetails_MultiAcccounts,              
isnull(A.PresentmentFlag,0) as PresentmentFlag,              
isnull(A.FormFlag,0) as FormFlag,               
Isnull(A.FormDetails_AcctNumOptional,'') as FormDetails_AcctNumOptional,              
Isnull(A.FormDetails_AltLookupLabel,'') as FormDetails_AltLookupLabel,              
Isnull(A.FormDetails_AltLookupVisibleLen,0) as FormDetails_AltLookupVisibleLen,              
Isnull(A.FormDetails_AltLookupMaxLen,0) as FormDetails_AltLookupMaxLen,              
Isnull(A.FormDetails_AddInfoLabel1,'') as FormDetails_AddInfoLabel1,              
Isnull(A.FormDetails_AddInfoReqFlag1,0) as FormDetails_AddInfoReqFlag1,              
Isnull(A.FormDetails_AddInfoValType1,'') as FormDetails_AddInfoValType1,              
Isnull(A.FormDetails_AddInfoVisibleLen1,0) as FormDetails_AddInfoVisibleLen1,              
Isnull(A.FormDetails_AddInfoMaxLen1,0) as FormDetails_AddInfoMaxLen1,              
Isnull(A.FormDetails_AddInfoLabel2,'') as FormDetails_AddInfoLabel2,              
Isnull(A.FormDetails_AddInfoReqFlag2,0) as FormDetails_AddInfoReqFlag2,              
Isnull(A.FormDetails_AddInfoValType2,'') as FormDetails_AddInfoValType2,              
Isnull(A.FormDetails_AddInfoVisibleLen2,0) as FormDetails_AddInfoVisibleLen2,              
Isnull(A.FormDetails_AddInfoMaxLen2,0) as FormDetails_AddInfoMaxLen2,              
Isnull(A.FormDetails_DispOnlyLabel1,'') as FormDetails_DispOnlyLabel1,              
Isnull(A.FormDetails_DispOnlyLen1,'') as FormDetails_DispOnlyLen1,              
Isnull(A.FormDetails_DispOnlyLabel2,'') as FormDetails_DispOnlyLabel2,              
Isnull(A.FormDetails_DispOnlyLen2,'') as FormDetails_DispOnlyLen2,              
Isnull(A.FormDetails_PrevBalDispFlag,'') as FormDetails_PrevBalDispFlag,              
Isnull(A.FormDetails_PrevPaidDispFlag,'') as FormDetails_PrevPaidDispFlag,              
Isnull(A.FormDetails_LatestBillDispFlag,'') as FormDetails_LatestBillDispFlag,              
Isnull(A.FormDetails_BalDueDispFlag,'') as FormDetails_BalDueDispFlag,              
Isnull(A.FormDetails_DueDateDispFlag,'') as FormDetails_DueDateDispFlag,              
Isnull(A.BillerHelpFlag,'') as BillerHelpFlag,              
Isnull(A.BillerHelpInfo_HelpTextEnglish,'') as BillerHelpInfo_HelpTextEnglish,              
Isnull(A.BillerHelpInfo_HelpTextSpanish,'') as BillerHelpInfo_HelpTextSpanish,              
Isnull(A.BillerHelpInfo_HelpURL,'') as BillerHelpInfo_HelpURL ,  
case when A.VendorFeeClass='F' Then @True Else @False End as MandatoryFee,  
case when A.VendorFeeClass='F' AND A.CustFee = 0 Then CustMinFee Else A.CustFee End as MandatoryFeeAmount
from softgate.Billers A                
Join Softgate.MerchIdState B on (A.TerminalNumber=B.MerchID)                
where B.StateCode=@AgentState and A.VendorID=@VendorName;
CREATE procedure [dbo].[st_GetProducts]    
(    
@IdAgent int    
)    
AS    
--Set nocount on     
Select   
D.IdProductsByProvider,    
D.IdGroup,    
D.VendorName, 
C.FormDetails_AddInfoLabel1,
C.FormDetails_AddInfoLabel2,
C.FormDetails_AltLookupLabel,
C.CustNameRequired,
C.SenderNameRequired,
C.PostingTimeCutoff,
C.PostingTimeDesc,
C.VendorAccountLengthMin,
C.VendorAccountLengthMax,
C.VendorTranAmtMin,
C.VendorTranAmtMax,
C.CustMaxFee,
C.CustMinFee

from Softgate.MerchIdState A  
Join Agent B on (A.StateCode=B.AgentState)  
Join Softgate.Billers C on (A.MerchId=C.TerminalNumber)  
Join ProductsByProvider D on (D.VendorID=C.VendorID)  
Where IdAgent=@IdAgent  
order by D.VendorName   


CREATE procedure [dbo].[st_GetGroups]      
(      
@IdAgent int      
)      
As      
--Set nocount on       
  
Select       
IdGroups,      
Description      
from Groups      
Where VendorSubType in   
(  
Select Distinct A.VendorSubType from softgate.Billers A  
Join softgate.MerchIdState B on (A.TerminalNumber=B.MerchID)  
Join Agent C on (B.Statecode=C.AgentState)  
Where IdAgent=@IdAgent  
)    
Order by Description


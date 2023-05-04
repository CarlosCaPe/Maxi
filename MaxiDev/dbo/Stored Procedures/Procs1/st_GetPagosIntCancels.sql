CREATE procedure [dbo].[st_GetPagosIntCancels]                  
(        
@IdFile Int Output    
)        
as                  
Set Nocount on     
Set @IdFile=0                
      
Select B.IdConsecutivoPagosInt as consecutivo,getdate() as CancellationDate  into #temp from Transfer A      
Join ConsecutivoPagosInt B on (A.IdTransfer=B.IdTransfer)      
Where IdGateway=14 and IdStatus=25          
    
    
If Exists (Select top 1 1 from #temp)    
Begin    
 Update PagosIntGeneradorIdFiles set IdFile=IdFile+1    
    Select @IdFile=IdFile from PagosIntGeneradorIdFiles    
End    
  
Delete  PagosIntLogFileTXT where IdTransfer in (Select IdTransfer from Transfer Where IdGateway=14 and IdStatus=25  )       
Insert into PagosIntLogFileTXT         
(        
IdTransfer,        
IdFileName,        
DateOfFileCreation,        
TypeOfTransfer         
)        
Select IdTransfer,@IdFile,GETDATE(),'Cancel' from Transfer Where IdGateway=14 and IdStatus=25    
    
Select  consecutivo,CancellationDate from #temp    
  
  
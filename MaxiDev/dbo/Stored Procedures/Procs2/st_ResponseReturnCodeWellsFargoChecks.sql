CREATE procedure [dbo].[st_ResponseReturnCodeWellsFargoChecks]                                              
(                                              
    @IdGateway  int,                                              
    @Claimcode  nvarchar(max),                                              
    @ReturnCode nvarchar(max),                                              
    @ReturnCodeType int,                                         
    @XmlValue xml,                                        
    @IsCorrect bit Output                                        
)                                         
AS                                        
Set nocount on                                        
Declare @Description nvarchar(max)                                          
Declare @IdStatusAction int                                          
Declare @IdTransfer int                                          
Declare @ActualIdStatus Int
Declare @str varchar(max)
declare @ReturnAllComission int 

set @str=''
                        
Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCode+','+Description                               
from GatewayReturnCode A  Join GatewayReturnCodeType B  on (A.IdGatewayReturnCodeType=B.IdGatewayReturnCodeType)   
where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCode                                          
                                          
Insert into WellsFargoRespoLog values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)                      
                  
If @ReturnCodeType=3                  
Begin                  
 Declare @DocHandle int                            
 EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlValue                             
 SELECT Name+'='+Value as variable  into #temp FROM OPENXML (@DocHandle, 'root/Variable',2)  WITH (Name varchar(max),Value varchar(max))                                   
 EXEC sp_xml_removedocument @DocHandle                                     
                   
 SELECT @str = COALESCE(@str + ';', '') + variable FROM #temp                  
 Set @Description=@Description+' '+@str                  
End                    
  
--Select @IdTransfer=IdTransfer from ConsecutivoPagosInt where IdConsecutivoPagosInt= CONVERT(int,@Claimcode)  
Select @IdTransfer=IdCheck,@ActualIdStatus=IdStatus from Checks where IdCheck = @Claimcode
                 
                            
If @IdStatusAction>0           
Begin                                            
	if @IdTransfer is not null and @ActualIdStatus<>@IdStatusAction                                                                       
	Begin                                           
		Update Checks set IdStatus=@IdStatusAction,DateStatusChange=GETDATE() where IdCheck=@IdTransfer                                            
		Exec st_SaveChangesToTransferLog @IdTransfer,@IdStatusAction,@Description,0                         
		--If @IdStatusAction=31 --- Rejected balance                        
		--Begin                        
		--	--Exec st_RejectedCreditToAgentBalance @IdTransfer   
		--	--EN rechazo afectar balance mas adelante                     
		--End                         
		                                                  
	End                                      
End                              
Else                              
Begin                              
	Select @Description='Return code UNKNOWN:'+@ReturnCode                              
	Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description                              
End                              
Set @IsCorrect=1

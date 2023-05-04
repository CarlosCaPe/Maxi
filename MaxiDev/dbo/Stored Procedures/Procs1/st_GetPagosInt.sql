
CREATE procedure [dbo].[st_GetPagosInt]              
(            
@IdFile INT output            
)            
as              
Set nocount on          
Set  @IdFile=0            
            
--- Get Minutes to wait to be send to service ---                                                        
Declare @MinutsToWait Int                                                        
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                                                 
--Set @MinutsToWait=0                                                       
                                                        
---  Update transfer to Attempt -----------------                                                        
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=14 and  IdStatus=20                                                      
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)              
---------------- Consecutive Number --------------------          
          
Insert into ConsecutivoPagosInt (IdTransfer)          
Select idtransfer from #temp          
        
----------------  New consecutive number -------------------        
        
If Exists (      
Select   top 1 1            
From Transfer A              
Join CountryCurrency B on (A.IdCountryCurrency=B.IdCountryCurrency)              
Join Currency C on (C.IdCurrency=B.IdCurrency)              
Join Agent D on (D.IdAgent=A.IdAgent)          
Join ConsecutivoPagosInt E on (E.IdTransfer=A.IdTransfer)              
Where IdGateway=14 and IdStatus=21        
      
)        
Begin        
 Update PagosIntGeneradorIdFiles set IdFile=IdFile+1        
    Select @IdFile=IdFile from PagosIntGeneradorIdFiles        
End        
                                                        
--------- Tranfer log ---------------------------                                                    
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                                                     
Select 21,IdTransfer,GETDATE() from #temp                                                      
------------------LogFileTXT---------------------------------------       
      
delete PagosIntLogFileTXT where IdTransfer in       
(Select A.IdTransfer from Transfer A            
Join CountryCurrency B on (A.IdCountryCurrency=B.IdCountryCurrency)              
Join Currency C on (C.IdCurrency=B.IdCurrency)              
Join Agent D on (D.IdAgent=A.IdAgent)          
Join ConsecutivoPagosInt E on (E.IdTransfer=A.IdTransfer)              
Where IdGateway=14 and IdStatus=21)           
Insert into PagosIntLogFileTXT             
(            
IdTransfer,            
IdFileName,            
DateOfFileCreation,            
TypeOfTransfer             
)            
--Select IdTransfer,@IdFile,GETDATE(),'Transfer' from #temp            
Select a.IdTransfer,@IdFile,GETDATE(),'Transfer' from transfer a Join ConsecutivoPagosInt E on (E.IdTransfer=A.IdTransfer)   
Where IdGateway=14 and IdStatus=21
            
            
Select               
DateOfTransfer as FechaDelGiro,              
E.IdConsecutivoPagosInt as Consecutivo,              
'USD' as MonedaRecibida,              
AmountInMN/ReferenceExRate as ValorDelGiro,              
C.CurrencyName as MonedaPago,              
AmountInMN as ValorAPagar,              
ReferenceExRate as Tasa,              
BeneficiaryName+' '+BeneficiaryFirstLastName+' '+BeneficiarySecondLastName as Beneficiario,              
BeneficiaryAddress as DireccionBeneficiario,              
BeneficiaryCity as CiudadBeneficiario,              
BeneficiaryPhoneNumber as TelefonoBeneficiario,              
GatewayBranchCode as CodigoDeAgencia,              
CustomerName+' '+CustomerFirstLastName+' '+CustomerSecondLastName as Remitente,              
D.AgentState as EstadoRemitente,              
'USA' as PaisRemitente,    
A.ClaimCode as Referencia              
From Transfer A              
Join CountryCurrency B on (A.IdCountryCurrency=B.IdCountryCurrency)              
Join Currency C on (C.IdCurrency=B.IdCurrency)      
Join Agent D on (D.IdAgent=A.IdAgent)          
Join ConsecutivoPagosInt E on (E.IdTransfer=A.IdTransfer)              
Where IdGateway=14 and IdStatus=21        

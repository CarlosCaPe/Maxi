CREATE procedure [dbo].[st_ReportRetainOperations]                  
(                  
@RetainDate datetime,                  
@IdGateway int,                   
@XMLIdPayer xml                  
)                  
as                  
Set nocount on                  
                  
Declare @IdPayerTable  table                  
(                  
IdPayer int                  
)                   
                  
Declare @DocHandle int                                
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XMLIdPayer                                 
INSERT INTO @IdPayerTable (IdPayer)                    
select convert(int,convert(varchar,id))      
from       
 (      
  SELECT text id FROM OPENXML (@DocHandle, 'Payers/p',2) where text is not null      
 )L                                   
EXEC sp_xml_removedocument @DocHandle                       
        
                  
Declare @Temp1 Table                   
(                  
DateOfTransfer DateTime,                  
ClaimCode nvarchar(max),                  
Beneficiary nvarchar(max),                  
Folio int,                  
AmountInDollars money,                  
AmountinMN money                  
)                  
             
                  
If @IdGateway=0                  
Begin                   
                  
 Insert into @Temp1 (DateOfTransfer,ClaimCode,Beneficiary,Folio,AmountInDollars,AmountinMN)                  
 Select A.DateOfTransfer,A.ClaimCode,A.BeneficiaryName+' '+A.BeneficiaryFirstLastName as Beneficiary,A.Folio,A.AmountInDollars,A.AmountInMN from transfer A                  
 Where                   
 Exists(Select 1 from TransferDetail where IdTransfer=A.IdTransfer  and DateOfMovement<=@RetainDate  and IdStatus<=21 )                  
 and ( (Select COUNT(1) from TransferDetail where IdTransfer=A.IdTransfer  and DateOfMovement< @RetainDate and IdStatus>21)=0   or (A.IdStatus<=21))          
 and IdGateway<>12                  
 and A.DateOfTransfer>'2009-01-01'        
 
                  
 Insert into @Temp1 (DateOfTransfer,ClaimCode,Beneficiary,Folio,AmountInDollars,AmountinMN)                  
 Select DateOfTransfer,ClaimCode,BeneficiaryName+' '+BeneficiaryFirstLastName as Beneficiary,Folio,AmountInDollars,AmountInMN from transferClosed A                    
 Where                   
 Exists(Select 1 from TransferClosedDetail where IdTransferClosed=A.IdTransferClosed  and DateOfMovement<=@RetainDate  and IdStatus<=21 )                  
 and ( (Select COUNT(1) from TransferClosedDetail where IdTransferClosed=A.IdTransferClosed  and DateOfMovement< @RetainDate and IdStatus>21)=0   or (A.IdStatus<=21))          
 and IdGateway<>12                  
 and A.DateOfTransfer>'2009-01-01'        
                  
                 
 Insert into @Temp1 (DateOfTransfer,ClaimCode,Beneficiary,Folio,AmountInDollars,AmountinMN)                  
 Select A.DateOfTransfer,A.ClaimCode,A.BeneficiaryName+' '+A.BeneficiaryFirstLastName as Beneficiary,A.Folio,A.AmountInDollars,A.AmountInMN from transfer A        
 Where                   
 Exists(Select 1 from TransferDetail where IdTransfer=A.IdTransfer  and DateOfMovement<=@RetainDate  and  (IdStatus<=21 or IdStatus=23))                  
 and ( (Select COUNT(1) from TransferDetail where IdTransfer=A.IdTransfer  and DateOfMovement< @RetainDate and (IdStatus>21 or IdStatus<>23))=0   or (A.IdStatus<=21 or A.IdStatus=23 ))          
 and IdGateway=12                   
 and A.DateOfTransfer>'2009-01-01'        
         
                   
 Insert into @Temp1 (DateOfTransfer,ClaimCode,Beneficiary,Folio,AmountInDollars,AmountinMN)                  
 Select DateOfTransfer,ClaimCode,BeneficiaryName+' '+BeneficiaryFirstLastName as Beneficiary,Folio,AmountInDollars,AmountInMN from transferClosed A                    
 Where          
 Exists(Select 1 from TransferClosedDetail where IdTransferClosed=A.IdTransferClosed  and DateOfMovement<=@RetainDate  and (IdStatus<=21 or IdStatus=23) )                  
 and ( (Select COUNT(1) from TransferClosedDetail where IdTransferClosed=A.IdTransferClosed  and DateOfMovement< @RetainDate and (IdStatus>21 or IdStatus<>23))=0   or (A.IdStatus<=21 or A.IdStatus=23))          
 and IdGateway=12                   
 and A.DateOfTransfer>'2009-01-01'        
        
                  
               
End       
                  
If @IdGateway<>0                  
Begin                   
            
 Insert into @Temp1 (DateOfTransfer,ClaimCode,Beneficiary,Folio,AmountInDollars,AmountinMN)                  
 Select A.DateOfTransfer,A.ClaimCode,A.BeneficiaryName+' '+A.BeneficiaryFirstLastName as Beneficiary,A.Folio,A.AmountInDollars,A.AmountInMN from transfer A        
 Join @IdPayerTable B on (A.IdPayer=B.IdPayer)                  
 Where                   
 Exists(Select 1 from TransferDetail where IdTransfer=A.IdTransfer  and DateOfMovement<=@RetainDate  and IdStatus<=21 )                  
 and ( (Select COUNT(1) from TransferDetail where IdTransfer=A.IdTransfer  and DateOfMovement< @RetainDate and IdStatus>21)=0   or (A.IdStatus<=21))          
 and IdGateway=@IdGateway                   
 and IdGateway<>12
 and A.DateOfTransfer>'2009-01-01'        
                   
                  
                  
 Insert into @Temp1 (DateOfTransfer,ClaimCode,Beneficiary,Folio,AmountInDollars,AmountinMN)                  
 Select DateOfTransfer,ClaimCode,BeneficiaryName+' '+BeneficiaryFirstLastName as Beneficiary,Folio,AmountInDollars,AmountInMN from transferClosed A                    
 Join @IdPayerTable B on (A.IdPayer=B.IdPayer)                  
 Where                   
 Exists(Select top 1 1 from TransferClosedDetail where IdTransferClosed=A.IdTransferClosed  and DateOfMovement<=@RetainDate  and IdStatus<=21 )                  
 and ( (Select COUNT(1) from TransferClosedDetail where IdTransferClosed=A.IdTransferClosed  and DateOfMovement< @RetainDate and IdStatus>21)=0   or (A.IdStatus<=21))          
 and IdGateway=@IdGateway                   
 and IdGateway<>12        
 and A.DateOfTransfer>'2009-01-01'        
                   
                  
 Insert into @Temp1 (DateOfTransfer,ClaimCode,Beneficiary,Folio,AmountInDollars,AmountinMN)                  
 Select A.DateOfTransfer,A.ClaimCode,A.BeneficiaryName+' '+A.BeneficiaryFirstLastName as Beneficiary,A.Folio,A.AmountInDollars,A.AmountInMN from transfer A        
 Join @IdPayerTable B on (A.IdPayer=B.IdPayer)                  
 Where                   
 Exists(Select 1 from TransferDetail where IdTransfer=A.IdTransfer  and DateOfMovement<=@RetainDate  and  (IdStatus<=21 or IdStatus=23))                  
 and ( (Select COUNT(1) from TransferDetail where IdTransfer=A.IdTransfer  and DateOfMovement< @RetainDate and (IdStatus>21 or IdStatus<>23))=0   or (A.IdStatus<=21 or A.IdStatus=23 ))          
 and IdGateway=12                   
 and IdGateway=@IdGateway          
 and A.DateOfTransfer>'2009-01-01'        
 
                   
 Insert into @Temp1 (DateOfTransfer,ClaimCode,Beneficiary,Folio,AmountInDollars,AmountinMN)                  
 Select DateOfTransfer,ClaimCode,BeneficiaryName+' '+BeneficiaryFirstLastName as Beneficiary,Folio,AmountInDollars,AmountInMN from transferClosed A                    
 Join @IdPayerTable B on (A.IdPayer=B.IdPayer)                  
 Where          
 Exists(Select 1 from TransferClosedDetail where IdTransferClosed=A.IdTransferClosed  and DateOfMovement<=@RetainDate  and (IdStatus<=21 or IdStatus=23) )                  
 and ( (Select COUNT(1) from TransferClosedDetail where IdTransferClosed=A.IdTransferClosed  and DateOfMovement< @RetainDate and (IdStatus>21 or IdStatus<>23))=0   or (A.IdStatus<=21 or A.IdStatus=23))          
 and IdGateway=12                   
 and IdGateway=@IdGateway      
 and A.DateOfTransfer>'2009-01-01'        
 
          
End          
                  
Select DateOfTransfer,ClaimCode,Beneficiary,Folio,AmountInDollars,AmountinMN from @Temp1 
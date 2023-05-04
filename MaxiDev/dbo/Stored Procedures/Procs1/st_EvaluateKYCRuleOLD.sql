CREATE PROCEDURE [dbo].[st_EvaluateKYCRuleOLD]                                        
(                                     
@CustomerName nvarchar(max),                                    
@CustomerFirstLastName nvarchar(max),                                    
@CustomerSecondLastName nvarchar(max),                                    
@BeneficiaryName nvarchar(max),                                    
@BeneficiaryFirstLastName nvarchar(max),                                    
@BeneficiarySecondLastName nvarchar(max),                                       
@IdPayer int,                                      
@IdPaymenttype int,                                      
@IdAgent int,                                                               
@IdCustomer int,                                                              
@IdBeneficiary int,                                       
@AmountInDollars money,                                                              
@AmountInMN money,                                                              
@IdCountryCurrency int                                      
                                                        
)                                        
AS                                        
Set nocount on                           
                        
                        
---------------------------------------------  Nexts lines must be commented------------------------------                         
/*                         
declare @RuleName as nvarchar(max)                          
Declare @Action as int                          
Declare @MessageInSpanish as nvarchar(max)                          
Declare @MessageInEnglish as nvarchar(max)                          
Declare @IsDenyList as bit                          
                          
Select @RuleName as RuleName,@Action as Action,@MessageInSpanish as MessageInSpanish, @MessageInEnglish as MessageInEnglish,@IsDenyList as IsDenyList                                      
*/                        
                             
                                      
--------------------- Id currency usa and country usa -------------------------------------------------------                                      
Declare @GlobalIDUSacurrency int                                      
Select @GlobalIDUSacurrency=convert(int,Value) from GlobalAttributes where Name='IdCountryCurrencyDollars'                  
                                      
                                      
-----------------------------Tabla temporal de reglas-----------------------------------------                                      
Create Table #Rules                                      
(                                      
Id int identity(1,1),                                      
IdRule int,                                       
RuleName nvarchar(max),                                      
IdPayer int,                                      
IdPaymentType int,                                      
Actor nvarchar(max),                                      
Symbol nvarchar(max),                                      
Amount money,                                      
AgentAmount bit,                                      
IdCountryCurrency int,                                      
TimeInDays int,                                      
Action int,                                      
MessageInSpanish nvarchar(max),                                      
MessageInEnglish nvarchar(max),                                    
IsDenyList bit                                      
)                                      
                                      
------------------------ Se cargan las reglas, solo aquelas que aplicaran ---------------                                      
Insert into #Rules                                      
(                                      
IdRule,                                       
RuleName,                                      
IdPayer,                    
IdPaymentType,                                      
Actor,                                      
Symbol,                           
Amount,                                      
AgentAmount,                                      
IdCountryCurrency,                                      
TimeInDays,                                      
Action,                                      
MessageInSpanish,                         
MessageInEnglish,                                    
IsDenyList                                      
)                                      
Select                             
IdRule,                                       
RuleName,                                      
IdPayer,                                      
IdPaymentType,                                  
Actor,                                      
Symbol,                                      
Amount,                                      
AgentAmount,                                      
IdCountryCurrency,                                     
TimeInDays,                                      
Action,                                      
MessageInSpanish,                                      
MessageInEnglish,                    
0                                      
from KYCRule With (nolock) Where (IdPayer=@IdPayer or IdPayer is NULL) And (IdCountryCurrency=@GlobalIDUSacurrency or IdCountryCurrency=@IdCountryCurrency)                                    
And IdGenericStatus=1  and  ( IdPaymentType=@IdPaymenttype  or IdPaymentType is NULL)  
--and IdRule >100                                   
             
                                    
--------------------- Si existe regla de beneficiario entonces llenar temporal de beneficiario---------------                                      
                                      
If EXISTS (Select 1 From #rules Where Actor='Beneficiary')                                              
Begin                                              
                                      
           
 Select IdBeneficiary into #Beneficiary From Beneficiary With (nolock) Where                                               
 Name=@BeneficiaryName AND                                               
 FirstLastName=@BeneficiaryFirstLastName AND                                              
 SecondLastName=@BeneficiarySecondLastName                                             
                                                
End                                        
          
                                      
----------------------------------------- declaracion de variables -----------------------------                                      
Declare @Id int,                                      
@IdPayerRule int,                                      
@IdPaymentTypeRule int,                            
@ActorRule nvarchar(max),                                      
@SymbolRule nvarchar(max),                                      
@AmountRule money,                                      
@AgentAmountRule bit,                                      
@IdCountryCurrencyRule int,                                      
@TimeInDaysRule int,                                      
@ActionRule int,                                      
@TotalAmount money                                      
                                      
Set @Id=1                                      
                                      
---------------------------------- Inicia ciclo principal de evaluacion de Reglas ---------------                                      
                                      
While exists (Select 1 from #Rules where @Id<=Id)                                      
Begin                                      
                                         
  Select                                       
  @IdPayerRule=IdPayer,                                      
  @IdPaymentTypeRule=IdPaymentType,                                      
  @ActorRule=Actor,                 
  @SymbolRule=Symbol,                                      
  @AmountRule=Amount,                                      
  @AgentAmountRule=AgentAmount,                                      
  @IdCountryCurrencyRule=IdCountryCurrency,                                      @TimeInDaysRule=TimeInDays,                                      
  @ActionRule=Action                                      
  From #Rules Where Id=@Id                                      
                                        
                                        
                                        
                                        
  Set @TotalAmount=0                                      
                                      
  If @ActorRule='Beneficiary' And @TimeInDaysRule>0                                      
  Begin                                      
  Select @TotalAmount=  ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars)  ELSE SUM( AmountInMN) END , 0)                                                             
  From  Transfer With (nolock)                                                             
    Where IdPayer = Case When @IdPayerRule IS NULL  THEN IdPayer ELSE @IdPayer END And                                       
    IdPaymentType = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else IdPaymentType End  And                                       
    IdBeneficiary in (Select IdBeneficiary From #Beneficiary) And                                         
    DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @TimeInDaysRule-1   And                                      
    IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)                  
                    
                                          
  End                                        
                                          
  If @ActorRule='Customer'  And @TimeInDaysRule>0                                      
  Begin                                      
  Select @TotalAmount=ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars)  ELSE SUM( AmountInMN) END , 0)                                                             
  From  Transfer With (nolock)                                                            
    Where IdPayer = Case When @IdPayerRule IS  Null Then IdPayer ELSE @IdPayer END And                                       
    IdPaymentType = Case When @IdPaymentTypeRule Is Not Null Then @IdPaymentType Else IdPaymentType End  And                                       
    IdCustomer = @IdCustomer And                                         
    DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @TimeInDaysRule -1  And                                      
    IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)        
          
                   
  --Select @IdCountryCurrencyRule,@IdPayerRule,@IdPayer,@IdPaymentTypeRule,@IdPaymentType,@IdCustomer,@TimeInDaysRule            
                
  --   Select   ISNULL( Case When 10 = 17 THEN SUM( AmountInDollars)  ELSE SUM( AmountInMN) END , 0)                                                             
  --From  Transfer                                                             
  --  Where             
  --  IdPayer  =Case When Null IS null  Then IdPayer ELSE 74 END And                                       
  --  --IdPaymentType = Case When null IS not null Then 1 Else IdPaymentType End  And                                       
  --  IdCustomer = 654491 And                                         
  --  DATEDIFF (day,DateOfTransfer,GETDATE() ) <= 1 -1  And                                      
  -- IdStatus Not In (25,16 ) --(25= Rejected, 16= Cancelled)               
                
             
                   
  End                                         
                     
                                        
  ---------------- Get the Amount Limit and Days to Add to Ask Id----------------------------                      
  If  @AgentAmountRule=1                                                         
   Select @AmountRule = AmountRequiredToAskId From AGENT Where IdAgent = @IdAgent                                       
  -------------------------------------------------------------------------------------------                                        
          
   If @SymbolRule='>'                                      
    Begin                                      
   if @IdCountryCurrencyRule=@GlobalIDUSacurrency                          
    Begin                                      
    If (@TotalAmount+@AmountInDollars) <=@AmountRule                                      
       Begin                          
         Delete #Rules Where Id=@Id                                      
       End                          End                          
   Else                          
   Begin                                      
    If (@TotalAmount+@AmountInMN) <= @AmountRule                          
        Begin                                      
           Delete #Rules Where Id=@Id                                      
        End                                      
     End                          
   End                          
                                        
    If @SymbolRule='<'                                      
    Begin                           
                              
   if @IdCountryCurrencyRule=@GlobalIDUSacurrency                          
    Begin                                      
    If (@TotalAmount+@AmountInDollars) >=@AmountRule                           
       Begin                                  
        Delete #Rules Where Id=@Id                          
       End                          
    End                           
   Else                  
   Begin                                     
    If (@TotalAmount+@AmountInMN) >= @AmountRule                                      
      Begin                          
       Delete #Rules Where Id=@Id                                      
      End                           
    End                           
  End                                      
                                 
    ------------------ Las reglas que se borran son las que no se cumplen ------------------------                                      
                                          
   Set @Id=@Id+1                                      
   Set @TotalAmount=0                                      
                                         
                                          
End                                      
                                    
                                    
----------------------------------------- variables for Deny List -----------------------------------------------                                    
                                    
Declare @CustomerIdKYCAction int                                  
Declare @BeneficiaryIdKYCAction int                                    
Declare @DenyListMessageInSpanish nvarchar(max)                                    
Declare @DenyListMessageInEnglish nvarchar(max)                                    
Set @CustomerIdKYCAction=0                                     
Set @BeneficiaryIdKYCAction=0                                    
                                    
                          
--------------------------- Deny List for customer -------------------------------------------------------------------------------------                                    
                        
Insert into #Rules (RuleName,Action,MessageInEnglish,MessageInSpanish,IsDenyList)                        
Select                        
'Deny List' as RuleName,                                      
C.IdKYCAction,                                    
C.MessageInEnglish,                                    
C.MessageInSpanish,                                    
1 as IsDenyList                        
From dbo.DenyListCustomer A With (nolock)                        
JOIN Customer B With (nolock) ON (A.IdCustomer=B.IdCustomer)                                    
JOIN DenyListCustomerActions C With (nolock) ON (C.IdDenyListCustomer=A.IdDenyListCustomer)                        
Where A.IdGenericStatus=1 AND B.Name=@CustomerName AND B.FirstLastName=@CustomerFirstLastName AND B.SecondLastName=@CustomerSecondLastName                                    
                                    
                                    
-------------------------- Deny List for Beneficiary ------------------------------------------------------------------------------------                                    
Insert into #Rules (RuleName,Action,MessageInEnglish,MessageInSpanish,IsDenyList)                              
Select                        
'Deny List' as RuleName,                                      
IdKYCAction,                                    
MessageInEnglish,                        
MessageInSpanish,                                    
1 as IsDenyList                                   
From dbo.DenyListBeneficiary A  With (nolock)             
JOIN Beneficiary B With (nolock) ON (A.IdBeneficiary=B.IdBeneficiary)                        
JOIN DenyListBeneficiaryActions C With (nolock) on (C.IdDenyListBeneficiary=A.IdDenyListBeneficiary)                       
Where A.IdGenericStatus=1 AND B.Name=@BeneficiaryName AND B.FirstLastName=@BeneficiaryFirstLastName AND B.SecondLastName=@BeneficiarySecondLastName                                    
                                    
                                   
                                    
Select RuleName,Action,MessageInSpanish,MessageInEnglish,IsDenyList from #Rules 
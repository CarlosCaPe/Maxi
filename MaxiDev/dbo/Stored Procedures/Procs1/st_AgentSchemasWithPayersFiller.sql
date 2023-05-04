CREATE Procedure [dbo].[st_AgentSchemasWithPayersFiller]            
AS  

DECLARE @IniDate DATETIME
SET @IniDate=GETDATE()

Truncate Table ExchangeRateFastRead  
            
declare @IdPaymentTypeDirectCash int          
set @IdPaymentTypeDirectCash =4          
          
declare @IdPaymentTypeCash int          
set @IdPaymentTypeCash =1          
          
declare @PaymentTypeCash  varchar(max)          
set @PaymentTypeCash= (select top 1 PaymentName from PaymentType where IdPaymentType= @IdPaymentTypeCash)          
  
Create table #temp  
(  
Id int identity(1,1),  
IdAgent Int  
)  
  
Insert into #temp (IdAgent)   
Select IdAgent from Agent where IdAgentStatus in (1,3,4)  
  
Declare @Contador int,@IdAgent int  
  
While exists (Select top 1 IdAgent from #temp )  
Begin  
  
Select top 1 @Contador=Id,@IdAgent=IdAgent from #temp  
  
Insert into ExchangeRateFastRead  
(  
IdAgent,  
IdAgentSchema,  
SchemaName,  
IdCurrency,  
CurrencyCode,  
CurrencyName,  
IdPaymentType,  
PaymentName,  
IdPayer,  
PayerCode,  
PayerName,  
AgentSpreadValue,  
PayerSpreadValue,  
SchemaSpreadValue,  
RefExRate,  
IdPayerConfig,  
IdCountry  
)  
Select   
 @IdAgent,          
 B.IdAgentSchema          
 ,B.SchemaName          
 ,D.IdCurrency          
 ,D.CurrencyCode           
 ,D.CurrencyName          
 --,LP.IdPaymentType          
 --,LP.PaymentName          
 ,case          
  when LP.IdPaymentType=@IdPaymentTypeDirectCash then @IdPaymentTypeCash          
  else LP.IdPaymentType          
 end IdPaymentType          
 ,case          
  when LP.IdPaymentType=@IdPaymentTypeDirectCash then @PaymentTypeCash          
  else LP.PaymentName          
 end PaymentName           
 ,LPy.IdPayer            
 ,LPy.PayerCode            
 ,LPy.PayerName        
 ,case      
 when A.EndDateSpread>GETDATE() then A.Spread       
 else 0      
 end AgentSpreadValue                   
 ,LPy.PayerSpreadValue            
 ,LPy.SchemaSpreadValue            
 ,LPy.RefExRate                 
 ,LPy.IdPayerConfig          
 ,C.IdCountry          
 from RelationAgentSchema A with (NOLock)            
  JOIN AgentSchema B with (NOLock) on (A.IdAgentSchema=B.IdAgentSchema)           
  JOIN Commission Co with (NOLock) on Co.IdCommission = B.IdCommission          
  JOIN CountryCurrency C with (NOLock) on (C.IdCountryCurrency=B.IdCountryCurrency)          
  JOIN Currency D with (NOLock) on (D.IdCurrency=C.IdCurrency)        
  cross join           
    (          
     Select Distinct PaymentName,D.IdPaymentType           
      From AgentSchema A with (NOLock)         
      JOIN AgentSchemaDetail B with (NOLock) on (A.IdAgentSchema=B.IdAgentSchema)           
      JOIN PayerConfig C  with (NOLock) on (C.IdPayerConfig=B.IdPayerConfig)          
      JOIN PaymentType D  with (NOLock) on (D.IdPaymentType=C.IdPaymentType)          
    )LP          
  inner join           
    (          
     Select DISTINCT            
       P.IdPayer,            
       P.PayerCode,            
       P.PayerName,            
       PC.SpreadValue PayerSpreadValue,            
       AD.SpreadValue SchemaSpreadValue,            
       --dbo.FunRefExRate(PC.IdCountryCurrency,PC.IdGateway,P.IdPayer) as RefExRate,--R.RefExRate,                 
       ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))) RefExRate, 
       PC.IdPayerConfig,            
       PC.IdPaymentType,           
       A.IdAgentSchema             
      from AgentSchema A  with (NOLock)             
       --JOIN RefExRate R on R.IdCountryCurrency =A.IdCountryCurrency AND R.Active =1                    
       JOIN AgentSchemaDetail AD  with (NOLock) on (A.IdAgentSchema=AD.IdAgentSchema)               
       JOIN PayerConfig PC  with (NOLock) on  (AD.IdPayerConfig=PC.IdPayerConfig) AND A.IdCountryCurrency =PC.IdCountryCurrency              
       JOIN Payer P  with (NOLock) on (PC.IdPayer=P.IdPayer)              
       LEFT JOIN RefExRate R1 with (NOLock) ON R1.IdCountryCurrency=PC.IdCountryCurrency and R1.Active=1 and R1.RefExRate<>0 and PC.IdGateway=R1.IdGateway and P.IdPayer=R1.IdPayer  
       LEFT JOIN RefExRate R2 with (NOLock) ON R2.IdCountryCurrency=PC.IdCountryCurrency and R2.Active=1 and R2.RefExRate<>0 and PC.IdGateway=R2.IdGateway and R2.IdPayer is NULL AND R1.RefExRate IS NULL
       LEFT JOIN RefExRate R3 with (NOLock) ON R3.IdCountryCurrency=PC.IdCountryCurrency and R3.Active=1 and R3.IdGateway is NULL and R3.IdPayer is NULL AND R1.RefExRate IS NULL AND R2.RefExRate IS NULL
      Where               
       PC.IdGenericStatus=1  AND P.IdGenericStatus=1                      
    )LPy on LPy.IdPaymentType = LP.IdPaymentType and LPy.IdAgentSchema=B.IdAgentSchema          
Where A.IdAgent=@IdAgent and B.IdGenericStatus=1           
order by B.SchemaName asc , PaymentName asc, (LPy.PayerSpreadValue+ LPy.SchemaSpreadValue +LPy.RefExRate) desc    
  
 Delete #temp where Id=@Contador  
  
End  
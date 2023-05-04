CREATE Procedure [dbo].[st_PayerToDepositBySchema]        
(        
@IdAgent int,     
@IdAgentSchema int        
)        
AS        
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;


DECLARE @IniDate DATETIME
SET @IniDate=GETDATE()       
  
declare @IdPaymentType int   
set @IdPaymentType =2 --DEPOSIT  
  
   select  
     DepositHold,    
  Folio,    
  IdGenericStatus,    
  IdPayer,    
  PayerCode,    
  PayerName,    
  IdPayerConfig,    
  IdCountryCurrency,    
  IdGateway,    
  PayerConfigIdGenericStatus,    
  IdPaymentType,    
  SchemaTempSpreadValue,  
  PayerSpreadValue,    
  SchemaSpreadValue,    
  RefExRate,    
  RequireBranch,  
  DivisorExchangeRate,
  IdFee,
  IdCommission,
  IdSpread      
from  
(     
     
  Select distinct      
   PC.DepositHold,      
   P.Folio,      
   P.IdGenericStatus,      
   P.IdPayer,      
   P.PayerCode,      
   P.PayerName,      
   PC.IdPayerConfig,      
   PC.IdCountryCurrency,      
   PC.IdGateway,      
   PC.IdGenericStatus PayerConfigIdGenericStatus,      
   PC.IdPaymentType,      
   
   case          
        when AD.EndDateTempSpread>GETDATE() then Isnull(AD.TempSpread,0)       
        else 0          
    end
    SchemaTempSpreadValue,  
   PC.SpreadValue PayerSpreadValue,      
   AD.SpreadValue SchemaSpreadValue,      
   --dbo.FunRefExRate(A.IdCountryCurrency,PC.IdGateway,P.IdPayer) as RefExRate,      
   ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))) RefExRate,   
   PC.RequireBranch,     
   C.DivisorExchangeRate ,
    AD.IdFee,
	AD.IdCommission,
	AD.IdSpread       
  from AgentSchema A with(nolock)       
   JOIN AgentSchemaDetail AD with(nolock) on (A.IdAgentSchema=AD.IdAgentSchema)         
   JOIN PayerConfig PC with(nolock) on (AD.IdPayerConfig=PC.IdPayerConfig) AND A.IdCountryCurrency =PC.IdCountryCurrency        
   JOIN CountryCurrency CC with(nolock) on CC.IdCountryCurrency =PC.IdCountryCurrency  
   JOIN Currency C with(nolock) on C.IdCurrency =CC.IdCurrency  
   JOIN Payer P with(nolock) on (PC.IdPayer=P.IdPayer)   
   LEFT JOIN RefExRate R1 with(nolock) ON R1.IdCountryCurrency=A.IdCountryCurrency and R1.Active=1 and R1.RefExRate<>0 and PC.IdGateway=R1.IdGateway and P.IdPayer=R1.IdPayer  
   LEFT JOIN RefExRate R2 with(nolock) ON R2.IdCountryCurrency=A.IdCountryCurrency and R2.Active=1 and R2.RefExRate<>0 and PC.IdGateway=R2.IdGateway and R2.IdPayer is NULL AND R1.RefExRate IS NULL
   LEFT JOIN RefExRate R3 with(nolock) ON R3.IdCountryCurrency=A.IdCountryCurrency and R3.Active=1 and R3.IdGateway is NULL and R3.IdPayer is NULL AND R1.RefExRate IS NULL AND R2.RefExRate IS NULL
    --Left JOIN RelationAgentSchema J on (J.IdAgent=@IdAgent and J.IdAgentSchema=A.IdAgentSchema and J.EndDateSpread>GETDATE())      
  Where A.IdAgentSchema=@IdAgentSchema         
  AND PC.IdGenericStatus=1  AND P.IdGenericStatus=1        
  AND PC.IdPaymentType=@IdPaymentType    
)L    
order by RefExRate+PayerSpreadValue+SchemaSpreadValue desc, PayerName asc

CREATE PROCEDURE [dbo].[st_PaymentTypeByAgent]          
(          
    @IdAgent int,
    @IdLenguage int = null
)          
AS          
/********************************************************************
<Author> Josue Moreno? </Author>
<app>Agente</app>
<Description>Obtiene esquemas por agente </Description>

<ChangeLog>
<log Date="DD/MM/AAA" Author="Jmoreno"> Creacion </log>

</ChangeLog>

*********************************************************************/ 
Set nocount on   


/*
 declare       
    @IdAgentSchema int,
    @IdLenguage int

       
Set nocount on   

*/
if @IdLenguage is null 
    set @IdLenguage=2   
        
          
      
select
  Distinct [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PAYMENTTYPE'+convert(varchar,D.IdPaymentType)) PaymentName
  , D.IdPaymentType           
 Into #Temp 
From  
 AgentSchema A WITH(NOLOCK)
JOIN 
 AgentSchemaDetail B WITH(NOLOCK)
on 
 (A.IdAgentSchema=B.IdAgentSchema)           
JOIN 
 PayerConfig C WITH(NOLOCK)
on 
 (
  C.IdPayerConfig=B.IdPayerConfig 
  AND A.IdCountryCurrency =C.IdCountryCurrency
  )          
JOIN 
 PaymentType D WITH(NOLOCK)
on 
 (D.IdPaymentType=C.IdPaymentType)          
Where 
 C.IdGenericStatus=1 
 and A.IdAgent = @IdAgent
 and A.IdGenericStatus=1        
             
If Exists (Select 1 from #Temp where IdPaymentType=1)        
   Delete  #Temp where IdPaymentType=4        
 Else        
   Update #Temp set IdPaymentType=1 Where IdPaymentType=4        
           
   Select PaymentName,IdpaymentType From #Temp  order by PaymentName



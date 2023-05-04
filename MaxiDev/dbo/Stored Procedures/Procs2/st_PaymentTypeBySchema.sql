CREATE PROCEDURE [dbo].[st_PaymentTypeBySchema]          
(          
    @IdAgentSchema int,
    @IdLenguage int = null
)          
AS          
--Set nocount on   

if @IdLenguage is null 
    set @IdLenguage=2   
        
          
--Select Distinct PaymentName,D.IdPaymentType           
select Distinct [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PAYMENTTYPE'+convert(varchar,D.IdPaymentType)) PaymentName,D.IdPaymentType           
Into #Temp From  AgentSchema A WITH(NOLOCK)          
JOIN AgentSchemaDetail B WITH(NOLOCK) on (A.IdAgentSchema=B.IdAgentSchema)           
JOIN PayerConfig C WITH(NOLOCK) on (C.IdPayerConfig=B.IdPayerConfig AND A.IdCountryCurrency =C.IdCountryCurrency)          
JOIN PaymentType D WITH(NOLOCK) on (D.IdPaymentType=C.IdPaymentType)          
Where C.IdGenericStatus=1 and A.IdAgentSchema=@IdAgentSchema  and A.IdGenericStatus=1        
          
-----  Las siguientes lineas son para el caso especial donde         
-- quitamos el Directed cash del drop donw de agente  , payment type          
-- pero si es el único entonces solo renombramos de directed cash a solo Cash pero dejamos su IdpaymentType=4        
If Exists (Select 1 from #Temp where IdPaymentType=1)        
   Delete  #Temp where IdPaymentType=4        
 Else        
   Update #Temp set /*PaymentName='CASH',*/ IdPaymentType=1 Where IdPaymentType=4        
           
   Select PaymentName,IdpaymentType From #Temp  order by PaymentName

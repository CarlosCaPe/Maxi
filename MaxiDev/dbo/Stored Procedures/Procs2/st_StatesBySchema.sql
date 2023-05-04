CREATE Procedure [dbo].[st_StatesBySchema]    
(    
	@IdAgentSchema int,
	@IdPaymentType int
)    
AS   

--Set nocount on 

--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 
Select Distinct G.StateName, G.IdState   
from  AgentSchema A WITH(NOLOCK)
INNER JOIN AgentSchemaDetail B WITH(NOLOCK) on (A.IdAgentSchema=B.IdAgentSchema)     
INNER JOIN PayerConfig C WITH(NOLOCK) on (B.IdPayerConfig=C.IdPayerConfig AND A.IdCountryCurrency =C.IdCountryCurrency )    
INNER JOIN Payer D WITH(NOLOCK) on (C.IdPayer=D.IdPayer)    
INNER JOIN Branch E WITH(NOLOCK) on (E.IdPayer=D.IdPayer)    
INNER JOIN City F WITH(NOLOCK) on (F.IdCity=E.IdCity)    
INNER JOIN [State] G WITH(NOLOCK) on (F.IdState=G.IdState)    
--JOIN Country H on (H.IdCountry=G.IdCountry)   
--JOIN CountryCurrency I on (I.IdCountryCurrency=A.IdCountryCurrency)
Where  A.IdAgentSchema=@IdAgentSchema 
AND C.IdGenericStatus=1    
AND E.IdGenericStatus=1  
AND D.IdGenericStatus = 1 --Fgonzalez pagadores habilitados
AND dbo.fnPaymentTypeComparison(@IdPaymentType,C.IdPaymentType)=1  
--AND H.IdCountry=I.IdCountry
Order by G.StateName
--OPTION (OPTIMIZE FOR UNKNOWN)
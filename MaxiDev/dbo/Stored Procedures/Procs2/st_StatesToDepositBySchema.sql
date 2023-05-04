CREATE Procedure [dbo].[st_StatesToDepositBySchema]  
(  
@IdAgentSchema int,
@IdPayer int
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

declare @IdPaymentType int 
set @IdPaymentType =2	--DEPOSIT

Select 
	Distinct G.StateName, G.IdState 
from  AgentSchema A with(nolock) 
	JOIN AgentSchemaDetail B with(nolock) on (A.IdAgentSchema=B.IdAgentSchema)   
	JOIN PayerConfig C with(nolock) on (B.IdPayerConfig=C.IdPayerConfig AND A.IdCountryCurrency =C.IdCountryCurrency )  
	JOIN Payer D with(nolock) on (C.IdPayer=D.IdPayer)  
	JOIN Branch E with(nolock) on (E.IdPayer=D.IdPayer)  
	JOIN City F with(nolock) on (F.IdCity=E.IdCity)  
	JOIN [State] G with(nolock) on (F.IdState=G.IdState)  
Where  B.IdAgentSchema=@IdAgentSchema   
	AND D.IdPayer =@IdPayer
	AND C.IdGenericStatus=1  
	AND E.IdGenericStatus=1
	AND C.IdPaymentType=@IdPaymentType  
Order by G.StateName

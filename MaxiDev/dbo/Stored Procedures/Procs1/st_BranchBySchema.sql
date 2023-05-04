CREATE Procedure [dbo].[st_BranchBySchema]    
(    
@IdAgentSchema INT,    
@IdCity INT,    
@IdPaymentType INT,    
@IdPayer INT,    
@IdGateway INT    
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

Select E.BranchName    
 ,E.IdBranch     
 ,E.IdPayer    
 ,E.IdCity    
 ,S.IdState    
 ,Ci.CityName    
 ,S.StateName    
 ,E.[Address]    
 ,E.zipcode    
 ,E.Phone    
 ,E.Fax    
 ,E.IdGenericStatus     
 ,GB.GatewayBranchCode    
 from  AgentSchema A with(nolock)   
 JOIN AgentSchemaDetail B with(nolock) on (A.IdAgentSchema=B.IdAgentSchema)     
 JOIN PayerConfig C with(nolock) on (B.IdPayerConfig=C.IdPayerConfig) AND A.IdCountryCurrency =C.IdCountryCurrency      
 JOIN Payer D with(nolock) on (C.IdPayer=D.IdPayer)    
 JOIN Branch E with(nolock) on (E.IdPayer=D.IdPayer)    
 Join GatewayBranch GB with(nolock) on GB.IdBranch = E.IdBranch and GB.IdGateway =  @IdGateway     
 JOIN City Ci with(nolock) on Ci.IdCity =E.IdCity    
 JOIN [State] S with(nolock) on S.IdState =Ci.IdState    
Where B.IdAgentSchema=@IdAgentSchema     
 AND C.IdGenericStatus=1 AND E.IdGenericStatus=1 AND D.IdGenericStatus=1    
 AND E.IdCity=@IdCity     
 and dbo.fnPaymentTypeComparison(@IdPaymentType,C.IdPaymentType)=1  
 AND D.IdPayer=@IdPayer       
Order by E.BranchName

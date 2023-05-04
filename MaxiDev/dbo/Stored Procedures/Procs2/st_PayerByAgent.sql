
CREATE Procedure [dbo].[st_PayerByAgent]  
(  
@IdAgent int
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

Declare @IdGenericStatusEnable int
set @IdGenericStatusEnable=1

select
	P.IdPayer,
	P.PayerCode,
	P.PayerName
from Payer P with(nolock) 
	inner join 
		(
			select distinct P.IdPayer
			from AgentSchema A with(nolock)
				--inner join RelationAgentSchema RA on RA.IdAgentSchema = A.IdAgentSchema
				inner join AgentSchemaDetail ASD with(nolock) on ASD.IdAgentSchema = A.IdAgentSchema
				inner join PayerConfig PC with(nolock) on (ASD.IdPayerConfig=PC.IdPayerConfig) AND A.IdCountryCurrency =PC.IdCountryCurrency  
				inner join Payer P with(nolock) on (PC.IdPayer=P.IdPayer) 
			where --A.IdGenericStatus=@IdGenericStatusEnable and
				PC.IdGenericStatus= @IdGenericStatusEnable and P.IdGenericStatus= @IdGenericStatusEnable
				and A.IdAgent=@IdAgent and A.IdGenericStatus in (1,2)
		)L on L.IdPayer = P.IdPayer

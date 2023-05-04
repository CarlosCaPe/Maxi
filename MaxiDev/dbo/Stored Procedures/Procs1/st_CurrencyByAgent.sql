
CREATE Procedure [dbo].[st_CurrencyByAgent]  
(  
    @IdAgent int,
    @IdLenguage int
)  
AS  
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

if @IdLenguage is null 
    set @IdLenguage=2

Select 
	C.IdCurrency
	,C.CurrencyCode 
	--,C.CurrencyName
    ,[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,C.CurrencyCode) CurrencyName
from Currency C with(nolock)
	inner join
		(
			select distinct C.IdCurrency	
            from AgentSchema A with(nolock)
			--from RelationAgentSchema RA  
				--JOIN AgentSchema A on (A.IdAgentSchema=RA.IdAgentSchema) 
				JOIN CountryCurrency CC with(nolock) on (CC.IdCountryCurrency=A.IdCountryCurrency)
				JOIN Currency C with(nolock) on (C.IdCurrency=CC.IdCurrency) 
				Where A.IdAgent=@IdAgent  and a.IdGenericStatus in (1,2)
		) L on L.IdCurrency =C.IdCurrency

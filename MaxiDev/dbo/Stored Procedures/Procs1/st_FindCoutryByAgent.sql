
CREATE procedure [dbo].[st_FindCoutryByAgent]
(
@IdAgent int,
@IdCountryCurency Int,
@CountryFlag nvarchar(max) output,
@CountryName nvarchar(max) output
)
As
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Select Top 1  @CountryFlag=Isnull(F.CountryFlag,'NotSelected.jpg'), @CountryName=F.CountryName 
from AgentSchema B with(nolock)
--from RelationAgentSchema A
--Join AgentSchema B on (A.IdAgentSchema=B.IdAgentSchema)
Join AgentSchemaDetail C with(nolock) on (C.IdAgentSchema=B.IdAgentSchema)
Join PayerConfig D with(nolock) on (D.IdPayerConfig=C.IdPayerConfig)
Join CountryCurrency E with(nolock) on (E.IdCountryCurrency=B.IdCountryCurrency)
Join Country F with(nolock) on (F.IdCountry=E.IdCountry)
Where IdAgent=@IdAgent and B.IdCountryCurrency=@IdCountryCurency

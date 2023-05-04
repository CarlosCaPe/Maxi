CREATE PROCEDURE [Corp].[st_GetSpecialCommissionRule]
@IdRule int
AS

/********************************************************************
<Author> Unknown </Author>
<app> Corporativo </app>
<Description> Consulta Reglas de Comisiones Especiales </Description>

<ChangeLog>
<log Date="04/10/2022" Author="cgarcia">MP-1218 - Se agrega consulta de Paises relacionados a la regla de comisiones epseciales</log>
</ChangeLog>

*********************************************************************/

declare @xml XML =
(
	SELECT 
		H.Commission,
		H.Goal,
		H.[From],
		H.[To]
	FROM [dbo].[SpecialCommissionRuleRanges] H WITH(NOLOCK)
	WHERE H.[IdSpecialCommissionRule]=@IdRule
	FOR XML AUTO, ROOT('root')
)

DECLARE @xmlCountries XML = 
(
	SELECT C.IdCountry
	FROM Corp.SpecialCommissionRuleRelCountry C WITH(NOLOCK)
	WHERE C.IdSpecialCommissionRule = @IdRule
	FOR XML AUTO, ROOT('root')

)


SELECT 
	R.IdSpecialCommissionRule,
	R.IdUserRequestedBy,
	R.IdUserAuthorizer,
	R.Description,
	R.Note,
	R.BeginDate,
	R.EndDate,
	R.IdAgent,
	ISNULL(A.AgentCode,'')+ ' ' +ISNULL(A.AgentName,'') AgentDisplayName,
	R.IdCountry,
	R.IdOwner,
	ISNULL(O.Name,'') +' '+ ISNULL(O.LastName,'')+' '+ ISNULL(O.SecondLastName,'') OwnerDisplayName,
	R.IdGenericStatus,
	R.[ApplyForTransaction],
	R.Accumulated, 
	@xml Detail,
	@xmlCountries Countries
FROM [dbo].[SpecialCommissionRule] R WITH(NOLOCK)
	left join Agent A WITH(NOLOCK) on A.IdAgent=R.IdAgent
	left join Owner O WITH(NOLOCK) on O.IdOwner=R.IdOwner
WHERE R.IdSpecialCommissionRule=@IdRule











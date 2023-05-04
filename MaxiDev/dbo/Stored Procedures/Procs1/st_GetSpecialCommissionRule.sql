CREATE PROCEDURE [dbo].[st_GetSpecialCommissionRule]
@IdRule int
AS

declare @xml XML =
(
	SELECT 
		H.Commission,
		H.Goal,
		H.[From],
		H.[To]
	FROM [dbo].[SpecialCommissionRuleRanges] H
	WHERE H.[IdSpecialCommissionRule]=@IdRule
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
	@xml Detail
FROM [dbo].[SpecialCommissionRule] R 
	left join Agent A on A.IdAgent=R.IdAgent
	left join Owner O on O.IdOwner=R.IdOwner
WHERE R.IdSpecialCommissionRule=@IdRule










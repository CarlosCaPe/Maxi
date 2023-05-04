CREATE PROCEDURE [Corp].[st_GetSpecialCommissionRulesByAgent_InternalSalesMonitor]
(
    @IdAgent int
)
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="04/10/2019" Author="jzuniga">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
                               
Set nocount on

SELECT 
	R.IdSpecialCommissionRule,
	CASE 
		WHEN R.IdAgent IS NOT NULL THEN ISNULL(A.AgentCode,'')+ ' ' +ISNULL(A.AgentName,'')
		WHEN R.IdOwner IS NOT NULL  THEN ISNULL(O.Name,'') +' '+ ISNULL(O.LastName,'')+' '+ ISNULL(O.SecondLastName,'')
	END Entity,
	R.Description,
	R.BeginDate,
	R.EndDate,
	ISNULL(UA.FirstName,'')+ ' '+ISNULL(UA.LastName,'')+' ' + ISNULL(UA.SecondLastName,'') AuthorizedBy,
	ISNULL(UR.FirstName,'')+ ' '+ISNULL(UR.LastName,'')+' ' + ISNULL(UR.SecondLastName,'') RequestedBy,
	R.[ApplyForTransaction],
	R.Note	
	
FROM [dbo].[SpecialCommissionRule] R WITH(NOLOCK)
	INNER JOIN Agent A WITH(NOLOCK) on A.IdAgent=R.IdAgent
	LEFT JOIN Owner O WITH(NOLOCK) on O.IdOwner=R.IdOwner
	LEFT JOIN Users UR WITH(NOLOCK) on UR.IdUser=R.IdUserRequestedBy
	LEFT JOIN Users UA WITH(NOLOCK) on UA.IdUser=R.[IdUserAuthorizedBy]
WHERE 
A.IdAgent = @IdAgent AND 
R.IdGenericStatus=1 






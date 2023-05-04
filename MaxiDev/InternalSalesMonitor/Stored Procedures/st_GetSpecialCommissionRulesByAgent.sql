CREATE PROCEDURE [InternalSalesMonitor].[st_GetSpecialCommissionRulesByAgent]
(
    @IdAgent int
)
AS
                               
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
	
FROM [dbo].[SpecialCommissionRule] R 
	INNER JOIN Agent A on A.IdAgent=R.IdAgent
	LEFT JOIN Owner O on O.IdOwner=R.IdOwner
	LEFT JOIN Users UR on UR.IdUser=R.IdUserRequestedBy
	LEFT JOIN Users UA on UA.IdUser=R.[IdUserAuthorizedBy]
WHERE 
A.IdAgent = @IdAgent AND 
R.IdGenericStatus=1 








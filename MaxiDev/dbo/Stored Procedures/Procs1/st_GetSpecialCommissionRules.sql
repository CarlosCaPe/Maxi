CREATE PROCEDURE [dbo].[st_GetSpecialCommissionRules]
(
    @IdUser int
)
AS
                               
Set nocount on

declare @IdUserType int= (Select IdUserType from Users where idUser=@IdUser )

declare @Users table(
idSeller int,
userName varchar(500)
)

If(@IdUserType=3)
BEGIN
	INSERT INTO @Users (idSeller, userName)
	exec [st_GetSellerChild] @IdUser
END

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
	left join Agent A on A.IdAgent=R.IdAgent
	left join Owner O on O.IdOwner=R.IdOwner
	left join Users UR on UR.IdUser=R.IdUserRequestedBy
	left join Users UA on UA.IdUser=R.[IdUserAuthorizedBy]
WHERE R.IdGenericStatus=1 and (@IdUserType=1 or (@IdUserType=3 and R.[IdUserAuthorizer] in (select idSeller from @Users)) or (@IdUserType=3 and R.EnterByIdUser in (select idSeller from @Users)) )




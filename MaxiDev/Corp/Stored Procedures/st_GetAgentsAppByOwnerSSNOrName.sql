CREATE PROCEDURE [Corp].[st_GetAgentsAppByOwnerSSNOrName] 

	-- Add the parameters for the stored procedure here

	@IdOwner INT

AS

/********************************************************************
<Author>adominguez</Author>
<app>MaxiCorp</app>
<Description>This stored gets agents by owner, SSN or Name with some interesting info</Description>

<ChangeLog>
<log Date="17/10/2018" Author="adominguez">Create</log>
<log Date="22/10/2018" Author="adominguez">Se cambia etiqueta Rep por AgentContact</log>
<log Date="22/10/2018" Author="adominguez">Se modifica query para consulta de nombre y apellidos del owner</log>
</ChangeLog>
********************************************************************/

declare @SSN varchar(max)

declare @Name varchar(max)



BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

		-- interfering with SELECT statements.

	SET NOCOUNT ON;

	set @SSN = (Select SSN from [dbo].[Owner] WITH(NOLOCK) where  IdOwner = @IdOwner)

	set @Name = (Select Name + LastName + SecondLastName from [dbo].[Owner] WITH(NOLOCK) where  IdOwner = @IdOwner)

    -- Insert statements for procedure here

	CREATE TABLE #SSSorName(

	IdOwner int,
	IdAgent int,
	AgentCode varchar(max),
	AgentName varchar(max),
	AgentContact varchar(max),
	AgentStatus varchar(max),
	SSN varchar(max),
	Rep varchar(max),
	SSNYes bit,
	NameYes bit)

	insert into #SSSorName
	SELECT

		A.IdOwner,

		A.[IdAgentApplication] IdAgent

		,A.[AgentCode] AgentCode

		,A.[AgentName] AgentName

		,A.AgentContact AgentContact

		,S.StatusName AgentStatus

		,O.SSN,

		O.Name Rep,

		case

		when O.SSN = @SSN then 1 else 0 end SSNYes,

		case

		when O.Name + O.LastName + O.SecondLastName = @Name then 1 else 0 end NameYes

	FROM [dbo].[AgentApplications] A WITH(NOLOCK)

	JOIN [dbo].AgentApplicationStatuses S WITH(NOLOCK) ON A.IdAgentApplicationStatus = S.IdAgentApplicationStatus

	JOIN [dbo].[Owner] O  WITH(NOLOCK) on O.IdOwner =  A.IdOwner

	--WHERE O.IdOwner = 2174

	where s.StatusName <> 'Released'

ORDER BY A.[AgentCode]

Select 
IdOwner ,
IdAgent ,
AgentCode ,
AgentName,
AgentContact ,
AgentStatus ,
SSN ,
Rep ,
SSNYes ,
NameYes 
from #SSSorName 
where ((SSNYes = 1) or (NameYes = 1))
--and IdOwner <> @IdOwner


drop table #SSSorName 

END

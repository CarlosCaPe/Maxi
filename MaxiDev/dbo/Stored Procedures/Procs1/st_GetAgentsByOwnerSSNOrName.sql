
--exec [dbo].[st_GetAgentsByOwnerSSNOrName]  3187

create PROCEDURE [dbo].[st_GetAgentsByOwnerSSNOrName] 

	-- Add the parameters for the stored procedure here

	@IdOwner INT

AS

/********************************************************************
<Author>adominguez</Author>
<app>MaxiCorp</app>
<Description>This stored gets agents by owner, SSN or Name with some interesting info</Description>

<ChangeLog>
<log Date="02/10/2018" Author="adominguez">Create</log>
<log Date="02/10/2018" Author="adominguez">Create</log>
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
	AgentClassName varchar(max),
	AgentStatus varchar(max),
	SSN varchar(max),
	Name varchar(max),
	SSNYes bit,
	NameYes bit)

	Insert into #SSSorName
	SELECT

	A.IdOwner,

		A.[IdAgent]

		,A.[AgentCode]

		,A.[AgentName]

		,AC.[Name] AgentClassName

		,S.[AgentStatus]

		,O.SSN

		,O.Name,

		case

		when O.SSN = @SSN then 1 else 0 end SSNYes,

		case

		when O.Name + O.LastName + O.SecondLastName = @Name then 1 else 0 end NameYes

	FROM [dbo].[Agent] A WITH(NOLOCK)

	JOIN [dbo].[AgentStatus] S WITH(NOLOCK) ON A.[IdAgentStatus] = S.[IdAgentStatus]

	JOIN [dbo].[AgentClass] AC WITH(NOLOCK) ON A.[IdAgentClass] = AC.[IdAgentClass]

	JOIN [dbo].[Owner] O  WITH(NOLOCK) on O.IdOwner =  A.IdOwner

	--WHERE O.IdOwner = @IdOwner

	ORDER BY A.[AgentCode]

	Select 
		IdOwner ,
		IdAgent ,
		AgentCode ,
		AgentName,
		AgentClassName ,
		AgentStatus ,
		SSN ,
		Name ,
		SSNYes ,
		NameYes 
		from #SSSorName 
		where ((SSNYes = 1) or (NameYes = 1))
		--and IdOwner <> @IdOwner


drop table #SSSorName 

	

END
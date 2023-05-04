CREATE PROCEDURE [Corp].[st_GetAgentsByOwnerVerifyAddress] 

	-- Add the parameters for the stored procedure here

	@IdOwner INT

AS

/********************************************************************
<Author>adominguez</Author>
<app>MaxiCorp</app>
<Description>This stored gets agents by owner, SSN or Name with some interesting info</Description>

<ChangeLog>
<log Date="17/10/2018" Author="adominguez">Create</log>
<log Date="24/10/2018" Author="adominguez">Se concatena el nombre con apellidos del owner</log>
</ChangeLog>
********************************************************************/

--declare @SSN varchar(max)

declare @Name varchar(max)

DECLARE @distance INT

declare @Address varchar(max)

declare @ZipCodeOwner varchar(MAX)



BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

		-- interfering with SELECT statements.

	SET NOCOUNT ON;

	--set @SSN = (Select SSN from [dbo].[Owner] where  IdOwner = @IdOwner)

	--set @Name = (Select Name from [dbo].[Owner] where  IdOwner = @IdOwner)

	set @Address = (Select AgentAddress from [dbo].[AgentApplications] WITH(NOLOCK) where IdAgentApplication = @IdOwner)

	set @ZipCodeOwner = (Select AgentZipCode from [dbo].[AgentApplications] WITH(NOLOCK) where IdAgentApplication = @IdOwner)

    -- Insert statements for procedure here



CREATE TABLE #verifyaddress(

	IdOwner int,

	IdAgent int,

	AgentCode varchar(max),

	AgentName varchar(max),

	AgentClassName varchar(max),

	--Rep varchar(max),

	AgentStatus varchar(max),

	SSN varchar(max),

	ZipCodeOwner varchar(max),

	AddressOwner varchar(max),

	Name varchar(max),

	[Address] varchar(max),

	ZipCode varchar(max),	

	[State] varchar(max),

	LN int,

	NameAgent varchar(max),

	[80pct] decimal,

	 Dif decimal)

SET NOCOUNT ON



INSERT INTO #verifyaddress

	SELECT

	A.IdOwner,

		A.[IdAgent]

		,A.[AgentCode]

		,A.[AgentName]

		,AC.[Name] AgentClassName

		,S.[AgentStatus] 

		,O.SSN

		,@ZipCodeOwner ZipCodeOwner

		,@Address AddressOwner

		,O.Name +' '+ O.LastName +' ' + O.SecondLastName,

		A.AgentAddress [Address],

		A.AgentZipcode ZipCode,

		A.AgentState [State],

		LEN(@Address) As LN,

		@Address,

	     (LEN(@Address)*0.2) AS '80pct',

	    [dbo].[fnLevenshtein] (@Address,A.AgentAddress, @distance) AS Dif

	FROM [dbo].[Agent] A WITH(NOLOCK)

	JOIN [dbo].[AgentStatus] S WITH(NOLOCK) ON A.[IdAgentStatus] = S.[IdAgentStatus]

	JOIN [dbo].[AgentClass] AC WITH(NOLOCK) ON A.[IdAgentClass] = AC.[IdAgentClass]

	JOIN [dbo].[Owner] O  WITH(NOLOCK) on O.IdOwner =  A.IdOwner

	--WHERE O.IdOwner = @IdOwner

	--ORDER BY A.[AgentCode]

	ORDER BY A.[AgentCode]





	Select 

	IdOwner ,

	IdAgent ,

	AgentCode ,

	AgentName ,

	AgentClassName ,

	AgentStatus ,

	SSN ,

	ZipCodeOwner ,

	AddressOwner ,

	Name ,

	[Address] ,

	ZipCode ,	

	[State] ,

	LN ,

	NameAgent ,

	[80pct] ,

	 Dif 

	  from #verifyaddress WITH(NOLOCK) where dif <= [80pct]

	DROP TABLE #verifyaddress

END






CREATE PROCEDURE [Corp].[st_GetAgentsAppByOwnerVerifyAddress] 

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

declare @Address varchar(max)

declare @Name varchar(max)

DECLARE @distance INT

declare @ZipCodeOwner varchar(MAX)

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

		-- interfering with SELECT statements.

	SET NOCOUNT ON;

	--set @Address = (Select Address from [dbo].[Owner] where  IdOwner = @IdOwner)

	set @Address = (Select AgentAddress from [dbo].[AgentApplications] WITH(NOLOCK) where IdAgentApplication = @IdOwner)

	set @ZipCodeOwner = (Select AgentZipCode from [dbo].[AgentApplications] WITH(NOLOCK) where IdAgentApplication = @IdOwner)

	--set @Name = (Select Name from [dbo].[Owner] where  IdOwner = @IdOwner)

    -- Insert statements for procedure here



	CREATE TABLE #verifyaddress(

	IdOwner int,

	IdAgent int,

	AgentCode varchar(max),

	AgentName varchar(max),

	Rep varchar(max),

	AgentStatus varchar(max),

	SSN varchar(max),

	AddressOwner varchar(max),

	ZipCodeOwner varchar(max),

	ZipCode varchar(max),

	Name varchar(max),

	LN int,

	[Address] varchar(max),

	--NameAgent varchar(max),

	[80pct] decimal,

	 Dif decimal)



SET NOCOUNT ON



INSERT INTO #verifyaddress

	SELECT

		A.IdOwner,

		A.[IdAgentApplication] IdAgent

		,A.[AgentCode] AgentCode

		,A.[AgentName] AgentName

		,A.AgentContact Rep

		--,AC.[Name] AgentClassName

		,S.StatusName AgentStatus

		,O.SSN

		,@Address AddressOwner

		,@ZipCodeOwner ZipCodeOwner,

		A.AgentZipcode ZipCode,

		O.Name +' '+ O.LastName +' ' + O.SecondLastName,

		LEN(@Address) As LN,

		A.AgentAddress,

	     (LEN(@Address)*0.2) AS '80pct',

	    [dbo].[fnLevenshtein] (@Address,A.AgentAddress, @distance) AS Dif

	FROM [dbo].[AgentApplications] A WITH(NOLOCK)

	JOIN [dbo].AgentApplicationStatuses S WITH(NOLOCK) ON A.IdAgentApplicationStatus = S.IdAgentApplicationStatus

	--JOIN [dbo].[AgentClass] AC (NOLOCK) ON A.[IdAgentClass] = AC.[IdAgentClass]

	JOIN [dbo].[Owner] O  WITH(NOLOCK) on O.IdOwner =  A.IdOwner

	WHERE A.IdAgentApplication <> @IdOwner

	AND s.StatusName <> 'Released'

	ORDER BY A.[AgentCode]



Select 

IdOwner ,

	IdAgent ,

	AgentCode ,

	AgentName ,

	Rep ,

	AgentStatus ,

	SSN ,

	AddressOwner ,

	ZipCodeOwner ,

	ZipCode ,

	Name,

	LN ,

	[Address] ,

	[80pct] ,

	 Dif 



from #verifyaddress with(nolock) where dif <= [80pct]





DROP TABLE #verifyaddress

--Select @Address

--Select * from [Agent] where AgentAddress like '%Bshdhd%' 

END

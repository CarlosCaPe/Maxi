CREATE PROCEDURE [dbo].[st_FetchAgentVerifyAddress]
(
	@AgentAddress	VARCHAR(200)
)
AS
/********************************************************************
<Author>maprado</Author>
<app>CorporativeServices.Agents</app>
<Description>This stored is used in CorporativeServices.Agents API</Description>

<ChangeLog>
	<log Date="18/08/2022" Author="maprado">Create method to return Agent data </log>
</ChangeLog>
*********************************************************************/
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @distance INT;

	DROP TABLE IF EXISTS  #AgentVerifyAddress;

	CREATE TABLE #AgentVerifyAddress(
		IdAgent				INT,
		AgentStateCode		VARCHAR(100),
		AgentName			VARCHAR(150),
		IdAgentStatus		INT,
		AgentStatusName		VARCHAR(100),
		IdAgentClass		INT,
		AgentClassName		VARCHAR(100),
		AgentAddress		VARCHAR(200),
		AgentZipcode		VARCHAR(20),
		AgentState			VARCHAR(20),
		IdOwner				INT,
		OwnerName			VARCHAR(150),
		IdAgentEntityType	INT,
		AgentEntityTypeName	VARCHAR(20),
		Ln					INT,
		Pct					DECIMAL,
		Dif					DECIMAL);

	INSERT INTO #AgentVerifyAddress
		SELECT
			A.IdAgent,
			A.AgentCode,
			A.AgentName,
			A.IdAgentStatus,
			S.AgentStatus,
			A.IdAgentClass,
			C.Name,
			A.AgentAddress,
			A.AgentZipcode,
			A.AgentState,
			A.IdOwner,
			CONCAT(O.Name,' ',O.LastName,' ',O.SecondLastName),
			A.IdAgentEntityType,
			ET.Name,
			LEN(A.AgentAddress),
			(LEN(A.AgentAddress)*0.2),
			[dbo].[fnLevenshtein] (@AgentAddress,A.AgentAddress, @distance)
		FROM Agent A WITH(NOLOCK)
		LEFT JOIN AgentStatus S WITH (NOLOCK) ON A.IdAgentStatus = S.IdAgentStatus
		LEFT JOIN AgentClass C WITH (NOLOCK) ON A.IdAgentClass = C.IdAgentClass
		LEFT JOIN Owner O WITH (NOLOCK) ON A.IdOwner = O.IdOwner
		LEFT JOIN AgentEntityType ET WITH (NOLOCK) ON A.IdAgentEntityType = ET.IdAgentEntityType
		ORDER BY A.AgentCode;

	SELECT
		IdAgent,
		AgentStateCode,
		AgentName,
		IdAgentStatus,
		AgentStatusName,
		IdAgentClass,
		AgentClassName,
		AgentAddress,
		AgentZipcode,
		AgentState,
		IdOwner,
		OwnerName,	
		IdAgentEntityType,
		AgentEntityTypeName,
		Ln,
		Pct,
		Dif
	FROM #AgentVerifyAddress WITH(NOLOCK)
	WHERE Dif <= Pct;

	DROP TABLE IF EXISTS  #AgentVerifyAddress;

END
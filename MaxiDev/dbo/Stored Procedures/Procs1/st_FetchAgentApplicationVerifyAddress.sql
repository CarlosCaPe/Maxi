CREATE PROCEDURE [dbo].[st_FetchAgentApplicationVerifyAddress]
(
	@AgentAddress	VARCHAR(200)
)
AS
/********************************************************************
<Author>maprado</Author>
<app>CorporativeServices.Agents</app>
<Description>This stored is used in CorporativeServices.Agents API</Description>

<ChangeLog>
	<log Date="18/08/2022" Author="maprado">Create method to return AgentApplication data </log>
</ChangeLog>
*********************************************************************/
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @distance INT;

	DROP TABLE IF EXISTS  #AgentApplicationVerifyAddress;

	CREATE TABLE #AgentApplicationVerifyAddress(
		IdAgentApplication			INT,
		AgentStateCode				VARCHAR(100),
		AgentName					VARCHAR(150),
		IdUserSeller				INT,
		SellerName					VARCHAR(150),
		IdAgentApplicationStatus	INT,
		AgentApplicationStatus		VARCHAR(50),
		IdOwner						INT,
		OwnerName					VARCHAR(150),
		Ln							INT,
		Pct							DECIMAL,
		Dif							DECIMAL);

	INSERT INTO #AgentApplicationVerifyAddress
		SELECT
			AP.IdAgentApplication,
			AP.AgentCode,
			AP.AgentName,
			AP.IdUserSeller,
			CONCAT(U.FirstName,' ',U.LastName,' ',U.SecondLastName),
			AP.IdAgentApplicationStatus,
			APS.StatusCodeName,
			AP.IdOwner,
			CONCAT(O.Name,' ',O.LastName,' ',O.SecondLastName),
			LEN(AP.AgentAddress),
			(LEN(AP.AgentAddress)*0.2),
			[dbo].[fnLevenshtein] (@AgentAddress,AP.AgentAddress, @distance)
		FROM AgentApplications AP WITH(NOLOCK)
		LEFT JOIN AgentApplicationStatuses APS WITH (NOLOCK) ON AP.IdAgentApplicationStatus = APS.IdAgentApplicationStatus
		LEFT JOIN Owner O WITH (NOLOCK) ON AP.IdOwner = O.IdOwner
		LEFT JOIN Users U WITH (NOLOCK) ON AP.IdUserSeller = U.IdUser
		ORDER BY AP.AgentCode;

	SELECT
		IdAgentApplication,
		AgentStateCode,
		AgentName,
		IdUserSeller,
		SellerName,
		IdAgentApplicationStatus,
		AgentApplicationStatus,
		IdOwner,
		OwnerName,
		Ln,
		Pct,
		Dif
	FROM #AgentApplicationVerifyAddress WITH(NOLOCK)
	WHERE Dif <= Pct;

	DROP TABLE IF EXISTS  #AgentApplicationVerifyAddress;

END
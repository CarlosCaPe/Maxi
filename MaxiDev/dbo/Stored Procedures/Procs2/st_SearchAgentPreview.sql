CREATE PROCEDURE [dbo].[st_SearchAgentPreview]
(
	@Search						NVARCHAR(200),
	@IdAgentPreviewModule		NVARCHAR(80),
	@OnlyEnable					BIT,
	@OnlyDisable				BIT,
	@TopSearch					BIT
)
AS
BEGIN
	DECLARE @PermissionsValue	NVARCHAR(MAX)

	SELECT
		@PermissionsValue = ga.Value
	FROM AgentPreviewModule ap WITH(NOLOCK)
		JOIN GlobalAttributes ga WITH(NOLOCK) ON ga.Name = ap.ModuleKey
	WHERE ap.IdAgentPreviewModule = @IdAgentPreviewModule

	SELECT 
		item IdAgent
	INTO #PermissionAgent
	FROM dbo.fnSplit(@PermissionsValue, ',') 

	SELECT
		CASE WHEN sp.IdAgent IS NOT NULL THEN 1 ELSE 0 END FeatureIsActive,
		a.IdAgent,
		a.AgentCode,
		a.AgentName,
		a.AgentAddress,
		a.AgentCity,
		a.AgentState,
		a.AgentZipcode,
		a.IdAgentStatus,
		ast.AgentStatus
	INTO #Temp
	FROM Agent a WITH(NOLOCK)
		LEFT JOIN #PermissionAgent sp ON sp.IdAgent = a.IdAgent
		JOIN AgentStatus ast WITH(NOLOCK) ON ast.IdAgentStatus = a.IdAgentStatus
	WHERE 
		(a.AgentCode LIKE CONCAT('%', @Search, '%') OR a.AgentName LIKE CONCAT('%', @Search, '%'))
		AND 
		(
			@OnlyEnable = 0 
			OR EXISTS (SELECT 1 FROM #PermissionAgent pa WHERE pa.IdAgent = a.IdAgent)
		)
		AND 
		(
			@OnlyDisable = 0
			OR NOT EXISTS (SELECT 1 FROM #PermissionAgent pa WHERE pa.IdAgent = a.IdAgent)		
		)

	IF @TopSearch = 1 
		SELECT TOP 1000
			t.*
		FROM #Temp t
		ORDER BY t.IdAgentStatus, t.IdAgent
	ELSE 
		SELECT 
			t.* 
		FROM #Temp t
		ORDER BY t.IdAgentStatus, t.IdAgent
END
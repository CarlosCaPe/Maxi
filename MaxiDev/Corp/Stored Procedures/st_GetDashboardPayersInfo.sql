CREATE PROCEDURE [Corp].[st_GetDashboardPayersInfo]
@IdGateway					INT,
@IncludeTodayTransactions 	BIT
AS
BEGIN

	DECLARE @FechaHoy DATE
	DECLARE @FechaBusqueda DATE
	DECLARE @FechaIni DATE
	
	
	SET @FechaHoy = CAST( GETDATE() AS DATE )
	
	
	IF(@IncludeTodayTransactions = 1)
		SELECT @FechaBusqueda = @FechaHoy
	ELSE
		SELECT @FechaBusqueda = CAST( dateadd(dd, -1, @FechaHoy ) AS DATE)
		
	SET @FechaIni = dateadd(mm, -7, @FechaBusqueda)
	
	--SELECT @FechaHoy AS FechaHoy, @FechaBusqueda AS FechaBusqueda, @FechaIni AS FechaIni
	

	
	SELECT T.IdTransfer, G.GatewayName, A.AgentCode,T.Folio, T.DateOfTransfer, T.DateStatusChange,S.StatusName, T.ClaimCode                  
	FROM Agent A with (nolock)
	Join Transfer T with (nolock) on (A.IdAgent=T.IdAgent)
	Join Status S with (nolock) on (T.IdStatus = S.IdStatus)
	Join Gateway G with (nolock) on (T.IdGateway = G.IdGateway)
	Left Join CountryCurrency C with (nolock) on (T.IdCountryCurrency = C.IdCountryCurrency)
	Left Join Country R with (nolock) on (R.IdCountry = C.IdCountry)                
	WHERE T.DateOfTransfer <= @FechaBusqueda
		AND (G.IdGateway = @IdGateway OR isnull(@IdGateway, 0) = 0)
		AND  T.IdStatus in ('70') --Update In Progress
	UNION 
	SELECT T.IdTransfer, G.GatewayName,A.AgentCode,T.Folio, T.DateOfTransfer, T.DateStatusChange,S.StatusName, T.ClaimCode                  
	FROM Agent A with (nolock)
	Join Transfer T with (nolock) on (A.IdAgent=T.IdAgent)
	Join Status S with (nolock) on (T.IdStatus = S.IdStatus)
	Join Gateway G with (nolock) on (T.IdGateway = G.IdGateway)
	Left Join CountryCurrency C with (nolock) on (T.IdCountryCurrency = C.IdCountryCurrency)
	Left Join Country R with (nolock) on (R.IdCountry = C.IdCountry)                
	WHERE T.DateStatusChange > = @FechaIni
		AND T.DateStatusChange < = @FechaBusqueda
		AND (G.IdGateway = @IdGateway OR isnull(@IdGateway, 0) = 0)
		AND  T.IdStatus in ('25','26','35')  -- Pending Cancel
	UNION-----------------------------------------------------------------------------------------------------------------------------------
	SELECT T.IdTransfer, G.GatewayName,A.AgentCode,T.Folio, T.DateOfTransfer, T.DateStatusChange,S.StatusName, T.ClaimCode                  
	FROM Agent A with (nolock)
	Join Transfer T with (nolock) on (A.IdAgent=T.IdAgent)
	Join Status S with (nolock) on (T.IdStatus = S.IdStatus)
	Join Gateway G with (nolock) on (T.IdGateway = G.IdGateway)
	Left Join CountryCurrency C with (nolock) on (T.IdCountryCurrency = C.IdCountryCurrency)
	Left Join Country R with (nolock) on (R.IdCountry = C.IdCountry)                
	WHERE T.DateOfTransfer <= @FechaBusqueda
		AND (G.IdGateway = @IdGateway OR isnull(@IdGateway, 0) = 0)
		AND  T.IdStatus in ('40')   -- Transfer Accepted
	UNION-----------------------------------------------------------------------------------------------------------------------------------
	SELECT T.IdTransfer, G.GatewayName,A.AgentCode,T.Folio, T.DateOfTransfer, T.DateStatusChange,S.StatusName, T.ClaimCode                  
	FROM  Agent A WITH (nolock)
	JOIN Transfer T WITH (nolock) ON (A.IdAgent=T.IdAgent)
	JOIN Status S WITH (nolock) ON (T.IdStatus = S.IdStatus)
	JOIN Gateway G WITH (nolock) ON (T.IdGateway = G.IdGateway)
	LEFT JOIN CountryCurrency C WITH (nolock) ON (T.IdCountryCurrency = C.IdCountryCurrency)
	LEFT JOIN Country R WITH (nolock) ON (R.IdCountry = C.IdCountry)                
	WHERE T.DateOfTransfer <= @FechaHoy
		AND (G.IdGateway = @IdGateway OR isnull(@IdGateway, 0) = 0)
		AND  T.IdStatus in ('21')   -- Pending Gateway
	ORDER BY G.GatewayName ASC, S.StatusName ASC, T.DateOfTransfer DESC
END



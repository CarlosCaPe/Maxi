CREATE PROCEDURE [Corp].[st_GetDashboardPayersInfo_UpdateInProgress]
@FechaBusqueda	DATETIME
AS
BEGIN

	SELECT G.GatewayName, A.AgentCode,T.Folio, T.DateOfTransfer, T.DateStatusChange,S.StatusName, T.ClaimCode                  
	FROM Agent A WITH (nolock)
		JOIN Transfer T WITH (nolock) on (A.IdAgent=T.IdAgent)
		JOIN Status S with (nolock) on (T.IdStatus = S.IdStatus)
		JOIN Gateway G with (nolock) on (T.IdGateway = G.IdGateway)
		LEFT JOIN CountryCurrency C with (nolock) on (T.IdCountryCurrency = C.IdCountryCurrency)
		LEFT JOIN Country R with (nolock) on (R.IdCountry = C.IdCountry)                
	WHERE T.DateOfTransfer <= @FechaBusqueda
		AND T.IdStatus = 70 --Update In Progress
	ORDER BY  S.StatusName,G.GatewayName, T.DateOfTransfer

END
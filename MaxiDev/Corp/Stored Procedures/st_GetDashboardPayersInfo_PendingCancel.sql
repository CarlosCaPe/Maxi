CREATE PROCEDURE [Corp].[st_GetDashboardPayersInfo_PendingCancel]
@FechaBusqueda	DATETIME
AS
BEGIN

	SELECT      G.GatewayName,A.AgentCode,T.Folio, T.DateOfTransfer, T.DateStatusChange,S.StatusName, T.ClaimCode
	                  
	FROM              Agent A with (nolock)
	Join Transfer T with (nolock) on (A.IdAgent=T.IdAgent)
	Join Status S with (nolock) on (T.IdStatus = S.IdStatus)
	Join Gateway G with (nolock) on (T.IdGateway = G.IdGateway)
	Left Join CountryCurrency C with (nolock) on (T.IdCountryCurrency = C.IdCountryCurrency)
	Left Join Country R with (nolock) on (R.IdCountry = C.IdCountry)
	                
	WHERE               T.DateStatusChange > = '2019-04-05'
	and               T.DateStatusChange < = '2020-10-15'
	
	AND  T.IdStatus in (25, 26, 35)  -- Pending Cancel
	
	ORDER BY  G.GatewayName, T.DateStatusChange

END
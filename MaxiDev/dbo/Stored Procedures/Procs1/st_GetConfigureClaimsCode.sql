
CREATE   PROCEDURE [dbo].[st_GetConfigureClaimsCode]
AS
/********************************************************************
<Author>Alejandro Cardenas</Author>
<date>26/01/2023</date>
<app>MaxiAgente</app>
<Description>Sp para obtener configuraciones api de ClaimsCode</Description>
*********************************************************************/
BEGIN
	SET NOCOUNT ON;

	-- Create Temp Table to save Docs
	DROP TABLE IF EXISTS  #ClaimsCodeConfigTmp;
	CREATE TABLE #ClaimsCodeConfigTmp(
		Name			NVARCHAR(MAX),
		Value			NVARCHAR(MAX));
	
	INSERT INTO #ClaimsCodeConfigTmp
		SELECT
			ga.Name,
			ga.Value
		FROM GlobalAttributes ga WITH (NOLOCK) 
		WHERE ga.Name IN ('ClaimsCodeServicesUrlToken', 'ClaimsCodeServicesClientId', 'ClaimsCodeServicesClientSecret', 'ClaimsCodeServicesGrantType','ClaimsCodeServicesUrl');

	SELECT
		MAX(CASE WHEN c.Name = 'ClaimsCodeServicesUrlToken' THEN c.Value END) [ClaimsCodeServicesUrlToken],
		MAX(CASE WHEN c.Name = 'ClaimsCodeServicesClientId' THEN c.Value END) [ClaimsCodeServicesClientId],
		MAX(CASE WHEN c.Name = 'ClaimsCodeServicesClientSecret' THEN c.Value END) [ClaimsCodeServicesClientSecret],
		MAX(CASE WHEN c.Name = 'ClaimsCodeServicesGrantType' THEN c.Value END) [ClaimsCodeServicesGrantType],
		MAX(CASE WHEN c.Name = 'ClaimsCodeServicesUrl' THEN c.Value END) [ClaimsCodeServicesUrl]
	FROM #ClaimsCodeConfigTmp c

	SET NOCOUNT OFF;
END

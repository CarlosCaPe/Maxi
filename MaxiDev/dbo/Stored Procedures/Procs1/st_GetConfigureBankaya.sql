
CREATE PROCEDURE [dbo].[st_GetConfigureBankaya]
AS
/********************************************************************
<Author>Miguel Prado</Author>
<date>07/07/2022</date>
<app>MaxiAgente</app>
<Description>Sp para obtener configuraciones api de Bankaya</Description>

<ChangeLog>
<log Date="06/09/2022" Author="maprado">replace WITH for temp table </log>
</ChangeLog>
*********************************************************************/
BEGIN
	SET NOCOUNT ON;

	-- Create Temp Table to save Docs
	DROP TABLE IF EXISTS  #BkyConfigTmp;
	CREATE TABLE #BkyConfigTmp(
		Name			NVARCHAR(MAX),
		Value			NVARCHAR(MAX));
	
	INSERT INTO #BkyConfigTmp
		SELECT
			ga.Name,
			ga.Value
		FROM GlobalAttributes ga WITH (NOLOCK) 
		WHERE ga.Name IN ('BankayaKeycloackAPIUrl', 'BankayaKeycloackClientId', 'BankayaKeycloackClientSecret', 'BankayaKeycloackGrantType','BankayaKYCUrl');

	SELECT
		MAX(CASE WHEN c.Name = 'BankayaKeycloackAPIUrl' THEN c.Value END) [BankayaKeycloackAPIUrl],
		MAX(CASE WHEN c.Name = 'BankayaKeycloackClientId' THEN c.Value END) [BankayaKeycloackClientId],
		MAX(CASE WHEN c.Name = 'BankayaKeycloackClientSecret' THEN c.Value END) [BankayaKeycloackClientSecret],
		MAX(CASE WHEN c.Name = 'BankayaKeycloackGrantType' THEN c.Value END) [BankayaKeycloackGrantType],
		MAX(CASE WHEN c.Name = 'BankayaKYCUrl' THEN c.Value END) [BankayaKYCUrl]
	FROM #BkyConfigTmp c

	SET NOCOUNT OFF;
END

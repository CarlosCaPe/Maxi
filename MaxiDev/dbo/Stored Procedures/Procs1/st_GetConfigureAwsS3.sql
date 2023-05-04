CREATE   PROCEDURE [dbo].[st_GetConfigureAwsS3]
AS
/********************************************************************
<Author>Miguel Prado</Author>
<date>30/01/2023</date>
<app>CorporativeServices.Agents</app>
<Description>Sp para obtener configuraciones de Aws S3 para api de creacion de Agentes y guardado de Archivos</Description>

<ChangeLog>
<log Date="XX/XX/XXXX" Author=""></log>
</ChangeLog>
*********************************************************************/
BEGIN
	SET NOCOUNT ON;

	-- Create Temp Table to save Conf
	DROP TABLE IF EXISTS  #AwsS3ConfigTmp;
	CREATE TABLE #AwsS3ConfigTmp(
		Name			NVARCHAR(MAX),
		Value			NVARCHAR(MAX));
	
	INSERT INTO #AwsS3ConfigTmp
		SELECT
			ga.Name,
			ga.Value
		FROM GlobalAttributes ga WITH (NOLOCK) 
		WHERE ga.Name IN ('AwsS3AccessKey', 'AwsS3SecretAccessKey', 'AwsS3BucketName','AwsS3Region');

	SELECT
		MAX(CASE WHEN c.Name = 'AwsS3AccessKey' THEN c.Value END) [AccessKey],
		MAX(CASE WHEN c.Name = 'AwsS3SecretAccessKey' THEN c.Value END) [SecretAccessKey],
		MAX(CASE WHEN c.Name = 'AwsS3BucketName' THEN c.Value END) [BucketName],
		MAX(CASE WHEN c.Name = 'AwsS3Region' THEN c.Value END) [Region]
	FROM #AwsS3ConfigTmp c

	SET NOCOUNT OFF;
END

CREATE   PROCEDURE [Services].[st_GetConfigureMoneyOrderUpdate]
AS
/********************************************************************
<Author>Alejandro Cardenas</Author>
<date>01/03/2023</date>
<app>MoneyOrderUpdate</app>
<Description>Sp para obtener configuraciones de ftp o sftp de Money Order Update</Description>
*********************************************************************/
BEGIN TRY
	SET NOCOUNT ON;

	-- Create Temp Table to save Data
	DROP TABLE IF EXISTS  #MoneyOrderUpdateConfigTmp;
	CREATE TABLE #MoneyOrderUpdateConfigTmp(
		[Key]			NVARCHAR(MAX),
		[Value]			NVARCHAR(MAX));
	
	INSERT INTO #MoneyOrderUpdateConfigTmp
		SELECT
			sa.[Key],
			sa.[Value]
		FROM Services.ServiceAttributes sa WITH (NOLOCK) 
		WHERE sa.Code = 'MONEYORDERUPDATE';

	SELECT
		MAX(CASE WHEN c.[Key] = 'HostName' THEN c.Value END) [HostName],
		MAX(CASE WHEN c.[Key] = 'UserName' THEN c.Value END) [UserName],
		MAX(CASE WHEN c.[Key] = 'Password' THEN c.Value END) [Password],
		CONVERT(INT, MAX(CASE WHEN c.[Key] = 'PortNumber' THEN c.Value END)) [PortNumber],
		MAX(CASE WHEN c.[Key] = 'SshHostKeyFingerprint' THEN c.Value END) [SshHostKeyFingerprint],
		CONVERT(Bit, MAX(CASE WHEN c.[Key] = 'IsSftp' THEN c.Value END)) [IsSftp],
		MAX(CASE WHEN c.[Key] = 'RemotePath' THEN c.Value END) [RemotePath],
		MAX(CASE WHEN c.[Key] = 'LocalPath' THEN c.Value END) [LocalPath]
	FROM #MoneyOrderUpdateConfigTmp c

	SET NOCOUNT OFF;
END TRY
BEGIN CATCH
	DECLARE @Message varchar(max) = ERROR_MESSAGE()
	DECLARE @ErrorLine varchar(20) = CONVERT(VARCHAR(20), ERROR_LINE())
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_GetConfigureMoneyOrderUpdate', GETDATE(), 'Line: ' + @ErrorLine + '. ' + @Message)
END CATCH


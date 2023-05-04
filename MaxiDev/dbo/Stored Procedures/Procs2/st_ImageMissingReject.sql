
CREATE PROCEDURE [dbo].[st_ImageMissingReject]
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/06/05" Author="mdelgado">s24_17 :: Add Notification of check rejected if agent allow notifications.. </log>
<log Date="2018/09/13" Author="jmolina">Add  WITH(NOLOCK)</log>
</ChangeLog>
********************************************************************/
	DECLARE @idCheck INT 
	DECLARE @iduser INT 
	DECLARE @Hours INT = 24
	DECLARE @Note NVARCHAR(MAX) = 'Cheque rechazado por falta de imágenes'

	SELECT @iduser = value FROM globalattributes WITH(NOLOCK) WHERE name ='SystemUserID'
	SELECT @Hours = value FROM globalattributes WITH(NOLOCK) WHERE name ='HoursImageMissingReject'

	SELECT IdCheck INTO #rejCheck 
	FROM checks WITH(NOLOCK)
	WHERE idstatus=41 
	AND DATEDIFF(MINUTE, DateOfMovement, GETDATE())>5 
	AND idcheck IN (select idcheck from checkholds WITH(NOLOCK) where IdStatus = 68 AND IsReleased IS NULL) 

	WHILE EXISTS (SELECT 1 FROM #rejCheck)
	BEGIN
		SELECT TOP 1 @idCheck = idCheck FROM #rejCheck
		UPDATE checkholds SET IsReleased = 0, DateOfLastChange = getdate() WHERE IdStatus = 68  AND IsReleased IS NULL AND idcheck=@idCheck 
		
		UPDATE Checks SET IdStatus = 31, DateStatusChange = GETDATE() WHERE IdCheck = @idCheck
		EXEC checks.st_SaveChangesToCheckLog @idCheck, 31, @Note,@iduser

		/*Afectar balance del agente*/
		EXEC [Checks].[st_CheckCancelToAgentBalance] @IdCheck, @iduser, 0
	
		EXEC [dbo].[st_RejectCheckNotification] @idCheck, @iduser, @Note

		DELETE FROM #rejCheck WHERE idCheck = @idCheck
	END

	DROP TABLE #rejCheck
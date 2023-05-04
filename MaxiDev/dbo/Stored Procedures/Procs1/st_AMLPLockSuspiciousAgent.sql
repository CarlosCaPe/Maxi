CREATE PROCEDURE [dbo].[st_AMLPLockSuspiciousAgent]
(
	@IdAgent		INT,
	@IdCountry		INT,
	@IdUser			INT,
	@HasError		BIT OUT,
	@Message		VARCHAR(500) OUT
)
AS

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="07/07/2022" Author="jdarellano" Name="#1">Performance: se agregan WITH (NOLOCK).</log>
</ChangeLog>
*********************************************************************/

BEGIN
	SET @HasError = 0;
	DECLARE @LastLock VARCHAR(25);

	SELECT
		@LastLock = sal.IdSuspiciousAgentLock
	FROM AMLP_SuspiciousAgentLock sal WITH (NOLOCK)
	WHERE 
		sal.IdAgent = @IdAgent 
		AND sal.IdCountry = @IdCountry 
		AND sal.IdUser <> @IdUser;

	DECLARE @AgentLockTimeOut INT = 10;

	SELECT
		@AgentLockTimeOut = ISNULL(ms.[Value], @AgentLockTimeOut)
	FROM AMLP_MonitorSettings ms WITH(NOLOCK)
	WHERE ms.IdMonitorSettings = 10;

	IF EXISTS (SELECT 1 FROM dbo.AMLP_SuspiciousAgentLock sal WITH (NOLOCK) WHERE sal.IdSuspiciousAgentLock = @LastLock AND DATEDIFF(MINUTE, sal.LastUpdate, GETDATE()) >= @AgentLockTimeOut)
	BEGIN
		DELETE FROM AMLP_SuspiciousAgentLock WHERE IdSuspiciousAgentLock = @LastLock;
		SET @LastLock = NULL;
	END

	IF @LastLock IS NOT NULL
	BEGIN
		SET @HasError = 1;
		SELECT
			@Message = CONCAT('The Agent "', a.AgentCode, ' ', a.AgentName, '" for "', c.CountryName, '" is under review by user "', u.UserLogin , 
			'" (since: ', FORMAT (sl.CreationDate, 'MM/dd/yyyy, HH:mm'),', last activity: ', FORMAT (sl.LastUpdate, 'MM/dd/yyyy, HH:mm') ,')')
		FROM dbo.AMLP_SuspiciousAgentLock sl WITH (NOLOCK)
			JOIN dbo.Agent a WITH (NOLOCK) ON a.IdAgent = sl.IdAgent
			JOIN dbo.Country c WITH (NOLOCK) ON c.IdCountry = sl.IdCountry
			JOIN dbo.Users u WITH (NOLOCK) ON u.IdUser = sl.IdUser
		WHERE sl.IdSuspiciousAgentLock = @LastLock;

		RETURN;
	END

	BEGIN TRANSACTION
	BEGIN TRY
		DELETE FROM dbo.AMLP_SuspiciousAgentLock WHERE IdUser = @IdUser AND  (IdAgent <> @IdAgent OR IdCountry <> @IdCountry);
		DECLARE @CurrentAgentLock  VARCHAR(25);

		SELECT
			@CurrentAgentLock = sal.IdSuspiciousAgentLock
		FROM dbo.AMLP_SuspiciousAgentLock sal WITH (NOLOCK)
		WHERE sal.IdAgent = @IdAgent 
		AND sal.IdCountry = @IdCountry 
		AND sal.IdUser = @IdUser;

		IF @CurrentAgentLock IS NULL
		BEGIN
			INSERT INTO dbo.AMLP_SuspiciousAgentLock (IdAgent, IdCountry, IdUser, CreationDate, LastUpdate)
			VALUES
			(
				@IdAgent,
				@IdCountry,
				@IdUser,
				GETDATE(),
				GETDATE()
			);
			
			SET @CurrentAgentLock = CONCAT(@IdAgent, '-', @IdCountry);
		END
		ELSE
			UPDATE dbo.AMLP_SuspiciousAgentLock SET
				LastUpdate = GETDATE()
			WHERE IdSuspiciousAgentLock = @CurrentAgentLock;

		SELECT
			@Message = CONCAT('The Agent "', a.AgentCode, ' ', a.AgentName, '" for "', c.CountryName, '" is under review for you (since: ', 
			FORMAT (sl.CreationDate, 'MM/dd/yyyy, HH:mm'),', last activity: ', FORMAT (sl.LastUpdate, 'MM/dd/yyyy, HH:mm') ,')')
		FROM dbo.AMLP_SuspiciousAgentLock sl WITH (NOLOCK)
			JOIN dbo.Agent a WITH (NOLOCK) ON a.IdAgent = sl.IdAgent
			JOIN dbo.Country c WITH (NOLOCK) ON c.IdCountry = sl.IdCountry
			JOIN dbo.Users u WITH (NOLOCK) ON u.IdUser = @IdUser
		WHERE sl.IdSuspiciousAgentLock = @CurrentAgentLock;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SET @HasError = 1;
		SET @Message = ERROR_MESSAGE();

	END CATCH
END

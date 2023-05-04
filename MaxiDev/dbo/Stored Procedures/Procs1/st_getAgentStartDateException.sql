CREATE PROCEDURE [dbo].[st_getAgentStartDateException](@idAgent INT = NULL, @session VARCHAR(200) )
AS
/********************************************************************
<Author>Fabián González</Author>
<app>MailSync</app>
<Description>Obtiene los dias al pasado que puede consultar recibos un agente</Description>

<ChangeLog>
<log Date="07/04/2017" Author="fgonzalez"> Creación </log>
<log Date="11/03/2020" Author="jcsierra"> Se cambia el tiempo default por 33 dias </log>
</ChangeLog>
*********************************************************************/

DECLARE @DefaultDays INT = 33

BEGIN TRY 

	IF (@idAgent IS NULL) BEGIN 
		DECLARE @idUser INT 
		SELECT @idUser=idUser FROM UsersSession (NOLOCK) WHERE SessionGuid =@Session
		SELECT @idAgent = IdAgent FROM AgentUser (NOLOCK) WHERE IdUser =@idUser
	END 
	
	DECLARE @MaxDays INT 
	SELECT 
		@MaxDays = MaximumDays 
	FROM AgentSelectDateException with(nolock) 
	WHERE idAgent = @idAgent

	SELECT ISNULL(@MaxDays, @DefaultDays) MaximumDays
END TRY
Begin Catch
	SELECT @DefaultDays AS MaximumDays
End Catch

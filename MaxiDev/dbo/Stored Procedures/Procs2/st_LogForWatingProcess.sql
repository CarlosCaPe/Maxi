
CREATE PROCEDURE [dbo].[st_LogForWatingProcess]
	@idAgent INT,
	@idUser INT,
	@SessionId UNIQUEIDENTIFIER,
	@module VARCHAR(MAX),
	@action VARCHAR(MAX),
	@application VARCHAR(MAX),
	@isError BIT,
	@ErrorDescription VARCHAR(MAX),
	@StackTrace VARCHAR(MAX)
AS

/********************************************************************
<Author>mdelgado</Author>
<app>MaxiCorp / MaxiAgent</app>
<Description>Insercion de registro de LOG para procesos de Waiting y Loading process</Description>

<ChangeLog>
<log Date="28/06/2017" Author="mdelgado">Creacion</log>
</ChangeLog>
********************************************************************/
BEGIN
	
	SET NOCOUNT ON;

	INSERT INTO [MAXILOG].[dbo].[LogForWaitingProcess]
           ([idAgent], [idUser], [SessionId], [Module], [Action], [Application], [isError], [ErrorDescription], [StackTrace])
     VALUES
           (@idAgent, @idUser, @SessionId, @module, @action, @application, @isError, @ErrorDescription, @StackTrace)

END


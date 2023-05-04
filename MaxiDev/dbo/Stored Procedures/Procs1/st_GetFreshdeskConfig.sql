CREATE PROCEDURE [dbo].[st_GetFreshdeskConfig]
(
	@Name		VARCHAR(30)
)
AS
BEGIN
	DECLARE @IdEnv INT

	SELECT
		@IdEnv = fe.Id
	FROM FD_Enviroment fe 
	WHERE fe.Name = @Name

	SELECT
		fe.*
	FROM FD_Enviroment fe WITH(NOLOCK)
	WHERE fe.Id = @IdEnv

	SELECT
		fec.[Key],
		fec.Value
	FROM FD_EnviromentConfigs fec WITH(NOLOCK)
	WHERE fec.IdFDEnviroment = @IdEnv

END
CREATE PROCEDURE Corp.st_ValidateCodifiedDepositFileName
	@CodifiedDepositFileName	NVARCHAR(1000),
	@HasError 					BIT OUT,
    @Message 					VARCHAR(max) OUT
AS
BEGIN
/********************************************************************
<Author>Cesar Garcia (cagarcia)</Author>
<app>Cronos</app>
<Description>Valida si existe un deposito con el mismo nombre de archivo existente</Description>

<ChangeLog>
<log Date="07/09/2022" Author="cagarcia">MP948 - Creacion del SP, validacion de deposito duplicado por medio del nombre del archivo</log>
</ChangeLog>
*********************************************************************/


	IF EXISTS (SELECT 1 FROM dbo.AgentDeposit WITH(NOLOCK) WHERE CodifiedDepositFileName = @CodifiedDepositFileName)
	BEGIN	
		SELECT @HasError = 1, @Message = 'File: "' + @CodifiedDepositFileName + '" already uploaded.'
	END
	ELSE
	BEGIN
		SELECT @HasError = 0, @Message = ''
	END

END 
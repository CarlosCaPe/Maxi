CREATE PROCEDURE [dbo].[st_DeleteAgentSchema]
(
	@IdAgentSchema INT
	,@EnterByIdUser INT
	,@IsSpanishLanguage INT
	,@HasError BIT OUTPUT
	,@MessageOut NVARCHAR(MAX) OUTPUT
)
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add ;</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
BEGIN TRY

	DECLARE @Values XML

	SET @HasError=0

	SET @Values= (SELECT * FROM AgentSchemaDetail WITH(NOLOCK) WHERE IdAgentSchema=@IdAgentSchema FOR XML AUTO,ELEMENTS)
	INSERT AuditLog (ObjectName, Operation, [Values], DateOfLastChange, EnterByIdUser)
	VALUES ('AgentSchemaDetail','DELETE',@Values,GETDATE(),@EnterByIdUser);

	SET @Values= (SELECT * FROM AgentSchema WITH(NOLOCK) WHERE IdAgentSchema=@IdAgentSchema FOR XML AUTO,ELEMENTS)
	INSERT AuditLog (ObjectName, Operation, [Values], DateOfLastChange, EnterByIdUser)
	VALUES ('AgentSchema','DELETE',@Values,GETDATE(),@EnterByIdUser);

	DELETE AgentSchemaDetail WHERE IdAgentSchema =@IdAgentSchema;
	DELETE AgentSchema WHERE IdAgentSchema =@IdAgentSchema;

	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'AgentSchemaDeleteOk');

END TRY
BEGIN CATCH

	SET @HasError=1
	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'AgentSchemaDeleteError')
	INSERT ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES(ERROR_PROCEDURE(),GETDATE(),ERROR_MESSAGE()) ; 

END CATCH

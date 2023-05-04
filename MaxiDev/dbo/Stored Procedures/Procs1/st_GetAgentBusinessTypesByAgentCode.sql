CREATE PROCEDURE [dbo].[st_GetAgentBusinessTypesByAgentCode]
(
    @AgentCode NVARCHAR(MAX)
)
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

BEGIN TRY
	DECLARE @XML AS XML
	DECLARE @TblAgentBusinessTypesByAgent TABLE (IdAgentBusinessType INT, Name NVARCHAR(MAX))
	SET @XML = (SELECT TOP 1 BusinessTypes FROM [dbo].[RelationAgentBusinessType] with(nolock) WHERE AgentCode = @AgentCode)
	IF @XML IS NOT NULL
	BEGIN
		INSERT INTO @TblAgentBusinessTypesByAgent (IdAgentBusinessType, Name)
		SELECT ABT.IdAgentBusinessType, ABT.Name
		FROM dbo.AgentBusinessType ABT with(nolock)
		JOIN @xml.nodes('/AgentBusinessTypes/IdAgentBusinessType') AS xmlABT(IdAgentBT)
		ON xmlABT.IdAgentBT.value('.','int') = ABT.IdAgentBusinessType;
	END
	SELECT IdAgentBusinessType, Name FROM @TblAgentBusinessTypesByAgent ORDER BY Name;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX)
    SELECT @ErrorMessage = ERROR_MESSAGE()                                             
    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_GetAgentBusinessTypesByAgentCode', GETDATE(), @ErrorMessage)   
END CATCH



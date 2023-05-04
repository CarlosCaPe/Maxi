
CREATE PROCEDURE [dbo].[st_GetAgentAppReleaseByAgentCode]
(
    
    @IdReference INT

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

DECLARE @AgentCode VARCHAR(MAX)
DECLARE @IdAgent INT
DECLARE @NameDocumentType VARCHAR(MAX)


		SET @AgentCode = (select AgentCode FROM AgentApplications with(nolock) WHERE IdAgentApplication = @IdReference)
		SET @IdAgent =  (SELECT IdAgent FROM Agent with(nolock) WHERE AgentCode = @AgentCode)
		--SET	@NameDocumentType = (SELECT Name FROM  documenttypes WHERE IdDocumentType = @IdDocumentType)
		--SET @IdDocumentType = (SELECT IdDocumentType FROM  documenttypes WHERE Name = @NameDocumentType AND IdType = 2)
  

  SELECT @IdAgent AS IdAgent

CREATE PROCEDURE [Corp].[st_GetAgentCollectionHours]

@IdAgent int

AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.

/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

    
	SELECT IdAgent, DayNumber, StartTime, EndTime from CollectionCallendarHours WITH(NOLOCK)
	WHERE IdAgent = @IdAgent
END

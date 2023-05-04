﻿CREATE PROCEDURE [dbo].[st_GetAgentBusinessTypes]
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

SELECT        
IdAgentBusinessType, Name, DateOfLastChange
FROM            
AgentBusinessType with(nolock)
ORDER BY Name





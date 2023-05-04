
CREATE procedure [dbo].[st_GetSchemaSpreadEditorHistory]
@IdAgent int,
@IdAgentSchema int
as

/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;


SELECT LA.[IdLogAgentSchemaSpread], LA.[IdAgentSchema], LA.[IdAgent], LA.[Spread], LA.[EndDateSpread], U.UserName, LA.[EnterDate]
FROM [dbo].[LogAgentSchemaSpread] AS LA with(nolock)
INNER JOIN [dbo].[Users] AS U with(nolock) ON LA.[EnterByIdUser] =U.IdUser
WHERE (LA.[IdAgent] = @IdAgent) AND (LA.[IdAgentSchema] = @IdAgentSchema)
ORDER BY LA.[EnterDate] DESC



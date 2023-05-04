CREATE TABLE [dbo].[RelationAgentBusinessType] (
    [IdRelation]       INT            IDENTITY (1, 1) NOT NULL,
    [AgentCode]        NVARCHAR (MAX) NOT NULL,
    [BusinessTypes]    XML            NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [IdUserLastChange] INT            NOT NULL,
    CONSTRAINT [PK_RelationAgentBusinessType] PRIMARY KEY CLUSTERED ([IdRelation] ASC)
);


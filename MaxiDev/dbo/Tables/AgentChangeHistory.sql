CREATE TABLE [dbo].[AgentChangeHistory] (
    [idAgentChangeHistory] INT            IDENTITY (1, 1) NOT NULL,
    [idAgent]              INT            NULL,
    [FieldData]            NVARCHAR (250) NULL,
    [FieldType]            NVARCHAR (25)  NULL,
    [DateOfChange]         DATETIME       NULL,
    [EnterByIdUser]        INT            NULL,
    [FromAgentApplication] BIT            DEFAULT ((0)) NULL,
    CONSTRAINT [PK_AgentChangeHistory] PRIMARY KEY CLUSTERED ([idAgentChangeHistory] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_AgentChangeHistory_idAgent_FieldType]
    ON [dbo].[AgentChangeHistory]([idAgent] ASC, [FieldType] ASC);


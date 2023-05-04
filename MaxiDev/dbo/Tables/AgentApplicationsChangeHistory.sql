CREATE TABLE [dbo].[AgentApplicationsChangeHistory] (
    [idAgentApplicationsChangeHistory] INT            IDENTITY (1, 1) NOT NULL,
    [idAgentApplication]               INT            NULL,
    [FieldData]                        NVARCHAR (MAX) NULL,
    [FieldType]                        NVARCHAR (MAX) NULL,
    [DateOfChange]                     DATETIME       NULL,
    [EnterByIdUser]                    INT            NULL,
    CONSTRAINT [PK_AgentApplicationsChangeHistory] PRIMARY KEY CLUSTERED ([idAgentApplicationsChangeHistory] ASC),
    CONSTRAINT [FK_AgentApplicationsChangeHistory_Agent] FOREIGN KEY ([idAgentApplication]) REFERENCES [dbo].[Agent] ([IdAgent])
);


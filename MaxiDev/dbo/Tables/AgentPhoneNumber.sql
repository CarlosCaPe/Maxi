CREATE TABLE [dbo].[AgentPhoneNumber] (
    [IdAgentPhoneNumber] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]            INT            NOT NULL,
    [PhoneNumber]        NVARCHAR (MAX) NOT NULL,
    [Comment]            NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AgentPhoneNumber] PRIMARY KEY CLUSTERED ([IdAgentPhoneNumber] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentPhoneNumber_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);


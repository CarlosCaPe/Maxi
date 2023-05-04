CREATE TABLE [dbo].[AgentBusinessTypes] (
    [IdAgentBusinessType] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (MAX) NOT NULL,
    [EnterByIdUser]       INT            NOT NULL,
    [DateOfLastChange]    DATETIME       NOT NULL,
    CONSTRAINT [PK_AgentBusinessType] PRIMARY KEY CLUSTERED ([IdAgentBusinessType] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentBusinesstype_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


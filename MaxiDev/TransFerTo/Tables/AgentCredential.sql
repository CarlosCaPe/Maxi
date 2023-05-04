CREATE TABLE [TransFerTo].[AgentCredential] (
    [IdAgentCredential] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]           INT            NOT NULL,
    [UserName]          NVARCHAR (MAX) NULL,
    [UserPassword]      NVARCHAR (MAX) NULL,
    [EnterByIdUser]     INT            NOT NULL,
    [DateOfCreation]    DATETIME       NOT NULL,
    [DateOfLastChange]  DATETIME       NOT NULL,
    [IdGenericStatus]   INT            NOT NULL,
    CONSTRAINT [PK_AgentCredential] PRIMARY KEY CLUSTERED ([IdAgentCredential] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCredential_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCredential_OPStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_AgentCredential_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


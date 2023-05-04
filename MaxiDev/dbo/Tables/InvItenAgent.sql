CREATE TABLE [dbo].[InvItenAgent] (
    [IdInvItemAgent]   INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]          INT      NOT NULL,
    [IdInvItem]        INT      NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    [EnterByIdUser]    INT      NOT NULL,
    CONSTRAINT [PK_InvItenAgent] PRIMARY KEY CLUSTERED ([IdInvItemAgent] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_InvItenAgent_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_InvItenAgent_InvItem] FOREIGN KEY ([IdInvItem]) REFERENCES [dbo].[InvItem] ([IdInvItem])
);


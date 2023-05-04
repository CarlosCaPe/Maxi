CREATE TABLE [dbo].[MaxiCollectionAssign] (
    [IdMaxiCollectionAssign] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]                INT      NOT NULL,
    [IdUser]                 INT      NULL,
    [DateOfAssign]           DATETIME NOT NULL,
    CONSTRAINT [PK_MaxiCollectionAssign] PRIMARY KEY CLUSTERED ([IdMaxiCollectionAssign] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_MaxiCollectionAssign_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_MaxiCollectionAssign_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [MaxiCollectionAssignDateOfAssignincludeIdAgentIdUser]
    ON [dbo].[MaxiCollectionAssign]([DateOfAssign] ASC)
    INCLUDE([IdAgent], [IdUser]) WITH (FILLFACTOR = 90);


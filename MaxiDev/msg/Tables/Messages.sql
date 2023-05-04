CREATE TABLE [msg].[Messages] (
    [IdMessage]         INT            IDENTITY (1, 1) NOT NULL,
    [IdMessageProvider] INT            NOT NULL,
    [IdUserSender]      INT            NOT NULL,
    [RawMessage]        NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]  DATETIME       NOT NULL,
    CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED ([IdMessage] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Messages_MessageProviders] FOREIGN KEY ([IdMessageProvider]) REFERENCES [msg].[MessageProviders] ([IdMessageProvider]),
    CONSTRAINT [FK_Messages_Users] FOREIGN KEY ([IdUserSender]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_Messages_IdMessageProvider]
    ON [msg].[Messages]([IdMessageProvider] ASC)
    INCLUDE([IdMessage], [DateOfLastChange], [RawMessage]);


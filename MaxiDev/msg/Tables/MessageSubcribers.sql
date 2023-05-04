CREATE TABLE [msg].[MessageSubcribers] (
    [IdMessageSubscriber] INT      IDENTITY (1, 1) NOT NULL,
    [IdMessage]           INT      NOT NULL,
    [IdUser]              INT      NOT NULL,
    [IdMessageStatus]     INT      NOT NULL,
    [DateOfLastChange]    DATETIME NOT NULL,
    [MessageIsRead]       BIT      DEFAULT ((0)) NOT NULL,
    [DateOfRead]          DATETIME NULL,
    CONSTRAINT [PK_MessageSubcribers] PRIMARY KEY CLUSTERED ([IdMessageSubscriber] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_MessageSubcribers_Messages] FOREIGN KEY ([IdMessage]) REFERENCES [msg].[Messages] ([IdMessage]),
    CONSTRAINT [FK_MessageSubcribers_MessageStatus] FOREIGN KEY ([IdMessageStatus]) REFERENCES [msg].[MessageStatus] ([IdMessageStatus]),
    CONSTRAINT [FK_MessageSubcribers_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ix2_MessageSubcribers]
    ON [msg].[MessageSubcribers]([IdUser] ASC, [IdMessageStatus] ASC)
    INCLUDE([IdMessageSubscriber], [IdMessage], [MessageIsRead]);


GO
CREATE NONCLUSTERED INDEX [ix_MessageSubcribers_IdMessage]
    ON [msg].[MessageSubcribers]([IdMessage] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MessageSubcribers_IdMessageStatus]
    ON [msg].[MessageSubcribers]([IdMessageStatus] ASC)
    INCLUDE([IdMessage], [IdMessageSubscriber]);


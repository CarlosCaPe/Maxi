CREATE TABLE [msg].[MessageSubscriberDetails] (
    [IdMessageSuscriberDetail] INT            IDENTITY (1, 1) NOT NULL,
    [IdMessageSubscriber]      INT            NOT NULL,
    [IdMessageStatus]          INT            NOT NULL,
    [UserSession]              NVARCHAR (MAX) NULL,
    [DateOfLastChange]         DATETIME       NULL,
    CONSTRAINT [PK_MessageDetails] PRIMARY KEY CLUSTERED ([IdMessageSuscriberDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_MessageSubscriberDetails_MessageStatus] FOREIGN KEY ([IdMessageStatus]) REFERENCES [msg].[MessageStatus] ([IdMessageStatus]),
    CONSTRAINT [FK_MessageSubscriberDetails_MessageSubcribers] FOREIGN KEY ([IdMessageSubscriber]) REFERENCES [msg].[MessageSubcribers] ([IdMessageSubscriber])
);


GO
CREATE NONCLUSTERED INDEX [IX_MessageSubscriberDetails_IdMessageSubscriber]
    ON [msg].[MessageSubscriberDetails]([IdMessageSubscriber] ASC)
    INCLUDE([IdMessageSuscriberDetail]);


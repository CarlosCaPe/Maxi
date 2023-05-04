CREATE TABLE [msg].[MessageLastValues] (
    [IdMessageLastValue] INT            IDENTITY (1, 1) NOT NULL,
    [IdMessageProvider]  INT            NOT NULL,
    [UserSession]        NVARCHAR (MAX) NOT NULL,
    [LastValueRetrieved] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_MessageLastValues] PRIMARY KEY CLUSTERED ([IdMessageLastValue] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_MessageLastValues_MessageProviders] FOREIGN KEY ([IdMessageProvider]) REFERENCES [msg].[MessageProviders] ([IdMessageProvider])
);


GO
CREATE NONCLUSTERED INDEX [IX_MessageLastValues_IdMessageProvider_UserSession]
    ON [msg].[MessageLastValues]([IdMessageProvider] ASC)
    INCLUDE([UserSession]);


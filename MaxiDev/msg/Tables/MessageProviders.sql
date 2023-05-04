CREATE TABLE [msg].[MessageProviders] (
    [IdMessageProvider] INT            IDENTITY (1, 1) NOT NULL,
    [ProviderName]      NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_MessageProviders] PRIMARY KEY CLUSTERED ([IdMessageProvider] ASC) WITH (FILLFACTOR = 90)
);


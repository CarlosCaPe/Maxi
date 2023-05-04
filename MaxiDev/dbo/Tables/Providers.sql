CREATE TABLE [dbo].[Providers] (
    [IdProvider]   INT           NOT NULL,
    [ProviderName] VARCHAR (255) NULL,
    CONSTRAINT [PK_Providers] PRIMARY KEY CLUSTERED ([IdProvider] ASC) WITH (FILLFACTOR = 90)
);


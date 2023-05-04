CREATE TABLE [dbo].[ProviderCredential] (
    [IdProviderCredential] INT            IDENTITY (1, 1) NOT NULL,
    [IdProvider]           INT            NOT NULL,
    [Login]                NVARCHAR (MAX) NOT NULL,
    [Password]             NVARCHAR (MAX) NOT NULL,
    [EnterByIdUser]        INT            NOT NULL,
    [DateOfLastChage]      NVARCHAR (MAX) NOT NULL,
    [IdGenericStatus]      INT            NOT NULL,
    CONSTRAINT [PK_ProviderCredential] PRIMARY KEY CLUSTERED ([IdProviderCredential] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ProviderCredential_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_ProviderCredential_Providers] FOREIGN KEY ([IdProvider]) REFERENCES [dbo].[Providers] ([IdProvider]),
    CONSTRAINT [FK_ProviderCredential_Users1] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


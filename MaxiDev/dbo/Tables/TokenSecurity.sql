CREATE TABLE [dbo].[TokenSecurity] (
    [IdToken]      INT              IDENTITY (1, 1) NOT NULL,
    [Token]        UNIQUEIDENTIFIER NOT NULL,
    [CreationDate] DATETIME         NOT NULL,
    [IsEnabled]    BIT              NOT NULL,
    CONSTRAINT [PK_TokenSecurity] PRIMARY KEY CLUSTERED ([IdToken] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_TokenSecurity_Token_IsEnabled_CreationDate]
    ON [dbo].[TokenSecurity]([Token] ASC, [IsEnabled] ASC, [CreationDate] ASC);


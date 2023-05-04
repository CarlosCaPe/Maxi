CREATE TABLE [dbo].[PayerSurrogateConfig] (
    [IdPayerSurrogateConfig] INT IDENTITY (1, 1) NOT NULL,
    [IdPayer]                INT NOT NULL,
    [IdPayerSurrogate]       INT NOT NULL,
    CONSTRAINT [PK_PayerSurrogateConfig] PRIMARY KEY CLUSTERED ([IdPayerSurrogateConfig] ASC),
    CONSTRAINT [FK_PayerSurrogateConfig_IdPayer] FOREIGN KEY ([IdPayer]) REFERENCES [dbo].[Payer] ([IdPayer]),
    CONSTRAINT [FK_PayerSurrogateConfig_IdPayerSurrogate] FOREIGN KEY ([IdPayerSurrogate]) REFERENCES [dbo].[Payer] ([IdPayer])
);


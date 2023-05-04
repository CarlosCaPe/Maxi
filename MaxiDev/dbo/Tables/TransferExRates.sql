CREATE TABLE [dbo].[TransferExRates] (
    [IdTransferExRates] INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]        INT            NULL,
    [Claimcode]         NVARCHAR (MAX) NULL,
    [IdGateway]         INT            NULL,
    [IdPayer]           INT            NULL,
    [RefExrate]         MONEY          NULL,
    [ExRate]            MONEY          NULL,
    CONSTRAINT [PK_TransferExRates] PRIMARY KEY CLUSTERED ([IdTransferExRates] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TransferExRates_Gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_TransferExRates_Payer] FOREIGN KEY ([IdPayer]) REFERENCES [dbo].[Payer] ([IdPayer])
);


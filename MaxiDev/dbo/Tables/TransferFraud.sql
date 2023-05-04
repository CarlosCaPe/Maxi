CREATE TABLE [dbo].[TransferFraud] (
    [IdTransferFraud] INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]      INT            NOT NULL,
    [IdAgent]         INT            NOT NULL,
    [AgentName]       NVARCHAR (MAX) NOT NULL,
    [DateOfTransfer]  DATETIME       NOT NULL,
    [AmountInDollars] MONEY          NOT NULL,
    [AmountInMN]      MONEY          NOT NULL,
    [Folio]           INT            NOT NULL,
    [EnterByIdUser]   INT            NOT NULL,
    [IdSeller]        INT            NOT NULL,
    [DateOfCreation]  DATETIME       NOT NULL,
    CONSTRAINT [PK_TransferFraud] PRIMARY KEY CLUSTERED ([IdTransferFraud] ASC) WITH (FILLFACTOR = 90)
);


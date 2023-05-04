CREATE TABLE [dbo].[PosSettlement] (
    [IdPosSettlement]  INT           IDENTITY (1, 1) NOT NULL,
    [IdPosTerminal]    INT           NOT NULL,
    [IdAgent]          INT           NOT NULL,
    [HostResponseCode] VARCHAR (200) NOT NULL,
    [HostResponseText] VARCHAR (200) NOT NULL,
    [MerchantId]       VARCHAR (200) NOT NULL,
    [TerminalId]       VARCHAR (200) NOT NULL,
    [TransactionDate]  VARCHAR (200) NOT NULL,
    [TransactionTime]  VARCHAR (200) NOT NULL,
    [CreationDate]     DATETIME      NOT NULL,
    [IdUser]           INT           NOT NULL,
    CONSTRAINT [PK_PosSettlement] PRIMARY KEY CLUSTERED ([IdPosSettlement] ASC),
    CONSTRAINT [FK_PosSettlement_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_PosSettlement_PosTerminal] FOREIGN KEY ([IdPosTerminal]) REFERENCES [dbo].[PosTerminal] ([IdPosTerminal]),
    CONSTRAINT [FK_PosSettlement_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


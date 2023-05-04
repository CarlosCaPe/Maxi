CREATE TABLE [Operation].[ProductTransfer] (
    [IdProductTransfer]             BIGINT   IDENTITY (1, 1) NOT NULL,
    [IdProvider]                    INT      NOT NULL,
    [IdAgentBalanceService]         INT      NOT NULL,
    [IdOtherProduct]                INT      NOT NULL,
    [IdAgent]                       INT      NOT NULL,
    [IdAgentPaymentSchema]          INT      NULL,
    [TotalAmountToCorporate]        MONEY    NOT NULL,
    [Amount]                        MONEY    NOT NULL,
    [Commission]                    MONEY    NOT NULL,
    [AgentCommission]               MONEY    NOT NULL,
    [CorpCommission]                MONEY    NOT NULL,
    [Fee]                           MONEY    NOT NULL,
    [TransactionFee]                MONEY    NOT NULL,
    [DateOfCreation]                DATETIME NOT NULL,
    [DateOfCancel]                  DATETIME NULL,
    [DateOfStatusChange]            DATETIME NOT NULL,
    [EnterByIdUser]                 INT      NOT NULL,
    [EnterByIdUserCancel]           INT      NULL,
    [IdStatus]                      INT      NOT NULL,
    [TransactionProviderDate]       DATETIME NULL,
    [TransactionProviderCancelDate] DATETIME NULL,
    [TransactionProviderID]         BIGINT   NULL,
    [OldIdTransfer]                 INT      NULL,
    [ProductData]                   XML      NULL,
    [DateOfCreationUTC]             DATETIME DEFAULT (getutcdate()) NULL,
    CONSTRAINT [PK_ProductTransfer] PRIMARY KEY CLUSTERED ([IdProductTransfer] ASC),
    CONSTRAINT [FK_ProductTransfer_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_ProductTransfer_AgentBalanceService] FOREIGN KEY ([IdAgentBalanceService]) REFERENCES [dbo].[AgentBalanceService] ([IdAgentBalanceService]),
    CONSTRAINT [FK_ProductTransfer_AgentPaymentSchema] FOREIGN KEY ([IdAgentPaymentSchema]) REFERENCES [dbo].[AgentPaymentSchema] ([IdAgentPaymentSchema]),
    CONSTRAINT [FK_ProductTransfer_OtherProduct] FOREIGN KEY ([IdOtherProduct]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts]),
    CONSTRAINT [FK_ProductTransfer_Provider] FOREIGN KEY ([IdProvider]) REFERENCES [dbo].[Providers] ([IdProvider]),
    CONSTRAINT [FK_ProductTransfer_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_ProductTransfer_UserCancel] FOREIGN KEY ([EnterByIdUserCancel]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_ProductTransfer_IdOtherProduct_TransactionProviderID]
    ON [Operation].[ProductTransfer]([IdOtherProduct] ASC, [TransactionProviderID] ASC)
    INCLUDE([IdProductTransfer], [IdProvider], [IdAgent], [DateOfCreation]);


GO
CREATE NONCLUSTERED INDEX [IX_ProductTransfer_IdAgentBalanceService]
    ON [Operation].[ProductTransfer]([IdAgentBalanceService] ASC)
    INCLUDE([IdProductTransfer], [IdProvider], [IdAgent], [DateOfCreation], [IdStatus], [TransactionProviderID]);


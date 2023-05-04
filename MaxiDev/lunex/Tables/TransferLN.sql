CREATE TABLE [lunex].[TransferLN] (
    [IdTransferLN]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [IdOtherProduct]        INT             NOT NULL,
    [IdAgent]               INT             NOT NULL,
    [EnterByIdUser]         INT             NOT NULL,
    [EnterByIdUserCancel]   INT             NULL,
    [Action]                NVARCHAR (MAX)  NOT NULL,
    [Login]                 NVARCHAR (MAX)  NULL,
    [LoginCancel]           NVARCHAR (MAX)  NULL,
    [Key]                   BIGINT          NOT NULL,
    [DateOfCreation]        DATETIME        NOT NULL,
    [DateOfCancel]          DATETIME        NULL,
    [TransactionDate]       DATETIME        NULL,
    [TransactionCancelDate] DATETIME        NULL,
    [TransactionID]         BIGINT          NOT NULL,
    [CID]                   NVARCHAR (1000) NOT NULL,
    [Entity]                NVARCHAR (1000) NOT NULL,
    [ExternalID]            NVARCHAR (1000) NOT NULL,
    [SKU]                   NVARCHAR (1000) NOT NULL,
    [SKUName]               NVARCHAR (1000) NOT NULL,
    [SKUType]               NVARCHAR (1000) NOT NULL,
    [Phone]                 NVARCHAR (1000) NOT NULL,
    [TopupPhone]            NVARCHAR (1000) NOT NULL,
    [Amount]                MONEY           NOT NULL,
    [LNStatus]              NVARCHAR (1000) NOT NULL,
    [IdStatus]              INT             NOT NULL,
    [D2Discount]            MONEY           NULL,
    [D1Discount]            MONEY           NOT NULL,
    [R1Discount]            MONEY           NULL,
    [R2Discount]            MONEY           NULL,
    [Commission]            MONEY           NOT NULL,
    [AgentCommission]       MONEY           NOT NULL,
    [CorpCommission]        MONEY           NOT NULL,
    [IdAgentPaymentSchema]  INT             NOT NULL,
    [IdSchema]              INT             NULL,
    [IdProductTransfer]     BIGINT          NOT NULL,
    [Pin]                   NVARCHAR (2000) NULL,
    [ReceivedValue]         MONEY           NULL,
    [ReceivedCurrency]      NVARCHAR (1000) NULL,
    [SenderName]            NVARCHAR (1000) NULL,
    [SenderAddress]         NVARCHAR (1000) NULL,
    [SenderCity]            NVARCHAR (1000) NULL,
    [SenderState]           NVARCHAR (1000) NULL,
    [AccessNumber]          NVARCHAR (1000) NULL,
    [ExpirationDate]        DATETIME        NULL,
    [Fee]                   MONEY           DEFAULT ((0)) NOT NULL,
    [WasPrint]              BIT             DEFAULT ((0)) NOT NULL,
    [DateOfPrint]           DATETIME        NULL,
    [ExRate]                MONEY           NULL,
    [AmountInMN]            MONEY           NULL,
    [CountryCurrency]       NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_TransferLN] PRIMARY KEY CLUSTERED ([IdTransferLN] ASC),
    CONSTRAINT [FK_TransferLN_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_TransferLN_OPStatus] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[OtherProductStatus] ([IdStatus]),
    CONSTRAINT [FK_TransferLN_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ncIndex_ProductTransferPhone]
    ON [lunex].[TransferLN]([IdProductTransfer] ASC)
    INCLUDE([Phone]);


GO
CREATE NONCLUSTERED INDEX [ix_TransferLN_IdOtherProduct_TransactionID]
    ON [lunex].[TransferLN]([IdOtherProduct] ASC, [TransactionID] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_TransferLN_Key]
    ON [lunex].[TransferLN]([Key] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TransferLN_IdAgent_EnterByIdUser_IdStatus_WasPrint]
    ON [lunex].[TransferLN]([IdAgent] ASC, [EnterByIdUser] ASC, [IdStatus] ASC, [WasPrint] ASC)
    INCLUDE([IdTransferLN], [Key], [SKUName], [TopupPhone], [IdProductTransfer], [Pin], [ReceivedValue], [DateOfPrint], [ExRate], [AmountInMN], [CountryCurrency]);


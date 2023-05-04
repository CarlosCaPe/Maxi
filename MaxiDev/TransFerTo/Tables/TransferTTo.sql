CREATE TABLE [TransFerTo].[TransferTTo] (
    [IdTransferTTo]            INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]                  INT            NOT NULL,
    [Action]                   NVARCHAR (MAX) NOT NULL,
    [Key]                      BIGINT         NOT NULL,
    [Msisdn]                   NVARCHAR (MAX) NOT NULL,
    [Destination_Msisdn]       VARCHAR (200)  NULL,
    [Product]                  NVARCHAR (MAX) NOT NULL,
    [Operator]                 NVARCHAR (MAX) NOT NULL,
    [OriginCurrency]           NVARCHAR (MAX) NOT NULL,
    [DestinationCurrency]      NVARCHAR (MAX) NOT NULL,
    [WholeSalePrice]           MONEY          NOT NULL,
    [RetailPrice]              MONEY          NOT NULL,
    [IdTransactionTTo]         BIGINT         NULL,
    [Country]                  NVARCHAR (MAX) NOT NULL,
    [OperatorReference]        NVARCHAR (MAX) NOT NULL,
    [LocalInfoAmount]          MONEY          NOT NULL,
    [LocalInfoCurrency]        NVARCHAR (MAX) NOT NULL,
    [LocalInfoValue]           MONEY          NOT NULL,
    [ReturnTimeStamp]          DATETIME       NOT NULL,
    [CancellationTimeStamp]    DATETIME       NULL,
    [CancellationMessage]      NVARCHAR (MAX) NULL,
    [Commission]               MONEY          NOT NULL,
    [AgentCommission]          MONEY          NOT NULL,
    [CorpCommission]           MONEY          NOT NULL,
    [IdStatus]                 INT            NOT NULL,
    [DateOfCreation]           DATETIME       NOT NULL,
    [IdOtherProduct]           INT            NOT NULL,
    [Login]                    NVARCHAR (MAX) NULL,
    [LoginCancel]              NVARCHAR (MAX) NULL,
    [IdSchema]                 INT            NULL,
    [EnterByIdUser]            INT            NULL,
    [IdCustomer]               INT            NULL,
    [IdCustomerFrequentNumber] INT            NULL,
    [NickName]                 NVARCHAR (MAX) NULL,
    [Response]                 NVARCHAR (MAX) NULL,
    [Request]                  NVARCHAR (MAX) NULL,
    [pinBased]                 BIT            NULL,
    [pinValidity]              NVARCHAR (MAX) NULL,
    [pinCode]                  NVARCHAR (MAX) NULL,
    [pinIvr]                   NVARCHAR (MAX) NULL,
    [pinSerial]                NVARCHAR (MAX) NULL,
    [pinValue]                 NVARCHAR (MAX) NULL,
    [pinOption1]               NVARCHAR (MAX) NULL,
    [pinOption2]               NVARCHAR (MAX) NULL,
    [pinOption3]               NVARCHAR (MAX) NULL,
    [IdProductTransfer]        BIGINT         CONSTRAINT [DF__TransferT__IdPro__1B1EE1BE] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TransferTTo] PRIMARY KEY CLUSTERED ([IdTransferTTo] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TransferTTo_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_TransferTTo_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_TransferTTo_CustomerFrequentNumber] FOREIGN KEY ([IdCustomerFrequentNumber]) REFERENCES [TransFerTo].[CustomerFrequentNumber] ([IdCustomerFrequentNumber]),
    CONSTRAINT [FK_TransferTTo_OPStatus] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[OtherProductStatus] ([IdStatus]),
    CONSTRAINT [FK_TransferTTo_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [TransferTToIdProductTransfer]
    ON [TransFerTo].[TransferTTo]([IdProductTransfer] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TransferTTo_IdStatus]
    ON [TransFerTo].[TransferTTo]([IdStatus] ASC)
    INCLUDE([IdTransferTTo], [Key], [IdTransactionTTo], [ReturnTimeStamp], [IdProductTransfer]);


GO
CREATE NONCLUSTERED INDEX [IX_TransferTTo_IdAgent_EnterByIdUser_ReturnTimeStamp]
    ON [TransFerTo].[TransferTTo]([IdAgent] ASC, [EnterByIdUser] ASC, [ReturnTimeStamp] ASC)
    INCLUDE([IdTransferTTo], [RetailPrice], [AgentCommission], [IdProductTransfer]);


GO
CREATE NONCLUSTERED INDEX [IX_TransferTTo_Destination_Msisdn]
    ON [TransFerTo].[TransferTTo]([Destination_Msisdn] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TransferTTo_IdCustomer]
    ON [TransFerTo].[TransferTTo]([IdCustomer] ASC)
    INCLUDE([IdProductTransfer]);


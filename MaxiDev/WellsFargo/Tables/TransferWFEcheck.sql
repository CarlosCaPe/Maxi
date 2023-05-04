CREATE TABLE [WellsFargo].[TransferWFEcheck] (
    [IdTransferWFEcheck] INT             IDENTITY (1, 1) NOT NULL,
    [IdAgent]            INT             NOT NULL,
    [Token]              NVARCHAR (MAX)  NOT NULL,
    [FirstName]          NVARCHAR (1000) NOT NULL,
    [LastName]           NVARCHAR (1000) NOT NULL,
    [ZipCode]            NVARCHAR (5)    NOT NULL,
    [Street]             NVARCHAR (MAX)  NOT NULL,
    [City]               NVARCHAR (MAX)  NOT NULL,
    [State]              NVARCHAR (MAX)  NOT NULL,
    [Country]            NVARCHAR (MAX)  NOT NULL,
    [PhoneNUmber]        NVARCHAR (MAX)  NOT NULL,
    [AccountNumberData]  VARBINARY (MAX) NOT NULL,
    [RoutingNumberData]  VARBINARY (MAX) NOT NULL,
    [AccountType]        NVARCHAR (1)    NOT NULL,
    [Amount]             MONEY           NOT NULL,
    [MinimunAmount]      MONEY           NOT NULL,
    [Request]            NVARCHAR (MAX)  NULL,
    [RequestDate]        DATETIME        NULL,
    [Response]           NVARCHAR (MAX)  NULL,
    [ResponseDate]       DATETIME        NULL,
    [ReasonCode]         NVARCHAR (MAX)  NULL,
    [ReconcilationID]    NVARCHAR (MAX)  NULL,
    [TransID]            NVARCHAR (MAX)  NULL,
    [Folio]              NVARCHAR (MAX)  NOT NULL,
    [EnterByIDUser]      INT             NOT NULL,
    [DateOfCreation]     DATETIME        NOT NULL,
    [Email]              NVARCHAR (MAX)  NULL,
    [IdAgentAccount]     INT             NULL,
    [BankName]           NVARCHAR (MAX)  NULL,
    [Alias]              NVARCHAR (MAX)  NULL,
    [Reference]          NVARCHAR (MAX)  NOT NULL,
    [ApplyDate]          DATETIME        NOT NULL,
    CONSTRAINT [PK_TransferWFEcheck] PRIMARY KEY CLUSTERED ([IdTransferWFEcheck] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TransferWFEcheck_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_TransferWFEcheck_User] FOREIGN KEY ([EnterByIDUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_TransferWFEcheck_EnterByIDUser]
    ON [WellsFargo].[TransferWFEcheck]([EnterByIDUser] ASC)
    INCLUDE([Token], [FirstName], [LastName], [ZipCode], [Street], [City], [State], [Country], [PhoneNUmber], [AccountNumberData], [RoutingNumberData], [AccountType], [DateOfCreation], [Email], [IdAgentAccount], [BankName], [Alias]);


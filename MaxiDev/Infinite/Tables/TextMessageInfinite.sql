CREATE TABLE [Infinite].[TextMessageInfinite] (
    [IdTextMessageInfinite] BIGINT         IDENTITY (1, 1) NOT NULL,
    [IdMessageType]         INT            NOT NULL,
    [IdPriority]            INT            NOT NULL,
    [IdCellularNumber]      BIGINT         NOT NULL,
    [Message]               NVARCHAR (MAX) NOT NULL,
    [IdTextMessageStatus]   INT            NOT NULL,
    [Attempts]              INT            DEFAULT ((0)) NOT NULL,
    [Request]               NVARCHAR (MAX) NULL,
    [Response]              NVARCHAR (MAX) NULL,
    [ProviderStatus]        INT            NULL,
    [ErrorMessageProvider]  NVARCHAR (MAX) NULL,
    [InserteredDate]        DATETIME       NOT NULL,
    [LastDateChange]        DATETIME       NOT NULL,
    [EnteredByUserId]       INT            NOT NULL,
    [AgentId]               INT            NULL,
    [GatewayId]             INT            NULL,
    [IsDelayed]             BIT            DEFAULT ((0)) NOT NULL,
    [DelayedDateTime]       DATETIME       NULL,
    [IdTransfer]            INT            NULL,
    PRIMARY KEY CLUSTERED ([IdTextMessageInfinite] ASC),
    FOREIGN KEY ([AgentId]) REFERENCES [dbo].[Agent] ([IdAgent]),
    FOREIGN KEY ([EnteredByUserId]) REFERENCES [dbo].[Users] ([IdUser]),
    FOREIGN KEY ([GatewayId]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    FOREIGN KEY ([IdCellularNumber]) REFERENCES [Infinite].[CellularNumber] ([IdCellularNumber]),
    FOREIGN KEY ([IdMessageType]) REFERENCES [Infinite].[MessageTypes] ([IdMessageType]),
    FOREIGN KEY ([IdPriority]) REFERENCES [Infinite].[Priority] ([IdPriority]),
    FOREIGN KEY ([IdTextMessageStatus]) REFERENCES [Infinite].[TextMessageStatus] ([IdTextMessageStatus]),
    FOREIGN KEY ([ProviderStatus]) REFERENCES [Infinite].[Status] ([StatusId])
);


GO
CREATE NONCLUSTERED INDEX [IX_TextMessageInfinite_IdMessageType_IdTextMessageStatus]
    ON [Infinite].[TextMessageInfinite]([IdMessageType] ASC, [IdTextMessageStatus] ASC)
    INCLUDE([IdCellularNumber], [IdTextMessageInfinite]);


GO
CREATE NONCLUSTERED INDEX [IX_TextMessageInfinite_IdCellularNumber]
    ON [Infinite].[TextMessageInfinite]([IdCellularNumber] ASC, [IdMessageType] ASC, [IdTextMessageStatus] ASC)
    INCLUDE([IdTextMessageInfinite], [IdPriority]);


GO
CREATE NONCLUSTERED INDEX [IX_TextMessageInfinite_IdTransfer]
    ON [Infinite].[TextMessageInfinite]([IdTransfer] ASC);


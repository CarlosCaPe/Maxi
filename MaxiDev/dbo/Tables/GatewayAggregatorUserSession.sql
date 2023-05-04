CREATE TABLE [dbo].[GatewayAggregatorUserSession] (
    [IdGatewayAggregatorUserSession] INT              IDENTITY (1, 1) NOT NULL,
    [IdGatewayUser]                  INT              NOT NULL,
    [LoginDate]                      DATETIME         NOT NULL,
    [GUID]                           UNIQUEIDENTIFIER NOT NULL,
    [LastUpdate]                     DATETIME         NOT NULL,
    CONSTRAINT [PK_GatewayAggregatorUserSession] PRIMARY KEY CLUSTERED ([IdGatewayAggregatorUserSession] ASC),
    CONSTRAINT [FK_GatewayAggregatorUserSession_GatewayUser] FOREIGN KEY ([IdGatewayUser]) REFERENCES [dbo].[GatewayUser] ([IdGatewayUser])
);


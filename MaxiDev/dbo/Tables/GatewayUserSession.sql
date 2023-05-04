CREATE TABLE [dbo].[GatewayUserSession] (
    [IdGatewayUserSession] INT              IDENTITY (1, 1) NOT NULL,
    [IdGatewayUser]        INT              NOT NULL,
    [LoginDate]            DATETIME         NOT NULL,
    [IPAddress]            VARCHAR (40)     NOT NULL,
    [GUID]                 UNIQUEIDENTIFIER NOT NULL,
    [LastUpdate]           DATETIME         NOT NULL,
    CONSTRAINT [PK_GatewayUserSession] PRIMARY KEY CLUSTERED ([IdGatewayUserSession] ASC),
    CONSTRAINT [FK_GatewayUserSession_GatewayUser] FOREIGN KEY ([IdGatewayUser]) REFERENCES [dbo].[GatewayUser] ([IdGatewayUser])
);


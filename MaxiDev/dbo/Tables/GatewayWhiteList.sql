CREATE TABLE [dbo].[GatewayWhiteList] (
    [IdGatewayWhiteList] INT          IDENTITY (1, 1) NOT NULL,
    [IdGateway]          INT          NOT NULL,
    [IPAddress]          VARCHAR (40) NOT NULL,
    [CreatedDate]        DATETIME     NOT NULL,
    [EnterByIdUser]      INT          NOT NULL,
    [IdStatus]           INT          NOT NULL,
    CONSTRAINT [PK_GatewayWhiteList] PRIMARY KEY CLUSTERED ([IdGatewayWhiteList] ASC),
    CONSTRAINT [FK_GatewayWhiteList_Gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_GatewayWhiteList_GenericStatus] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_GatewayWhiteList_IdUser] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


CREATE TABLE [dbo].[GatewayUser] (
    [IdGatewayUser] INT          IDENTITY (1, 1) NOT NULL,
    [IdGateway]     INT          NOT NULL,
    [UserName]      VARCHAR (50) NOT NULL,
    [Password]      VARCHAR (50) NOT NULL,
    [Salt]          VARCHAR (50) NOT NULL,
    [CreatedDate]   DATETIME     NOT NULL,
    [EnterByIdUser] INT          NOT NULL,
    [IdStatus]      INT          NOT NULL,
    CONSTRAINT [PK_GatewayUser] PRIMARY KEY CLUSTERED ([IdGatewayUser] ASC),
    CONSTRAINT [FK_GatewayUser_Gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_GatewayUser_GenericStatus] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_GatewayUser_IdUser] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [UQ_GatewayUser_UserName] UNIQUE NONCLUSTERED ([UserName] ASC)
);


CREATE TABLE [dbo].[GatewayConfigMail] (
    [Mail]                NVARCHAR (MAX) NOT NULL,
    [IdGateway]           INT            NOT NULL,
    [IdGenericStatus]     INT            NOT NULL,
    [IsInfoRequired]      BIT            DEFAULT ((1)) NOT NULL,
    [IdUser]              INT            NULL,
    [DateOfLastChange]    DATETIME       NULL,
    [IdGatewayConfigMail] INT            IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [FK_GatewayConfigMail_Gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_GatewayConfigMail_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);


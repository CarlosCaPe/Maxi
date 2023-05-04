CREATE TABLE [dbo].[GatewayReturnCode] (
    [IdGatewayReturnCode]     INT            IDENTITY (1, 1) NOT NULL,
    [IdGateway]               INT            NOT NULL,
    [IdGatewayReturnCodeType] INT            NOT NULL,
    [ReturnCode]              NVARCHAR (16)  NOT NULL,
    [Description]             NVARCHAR (512) NULL,
    [IdStatusAction]          INT            NULL,
    [idLenguage]              INT            NULL,
    CONSTRAINT [PK_GatewayReturnCode] PRIMARY KEY CLUSTERED ([IdGatewayReturnCode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_GatewayReturnCode_Gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_GatewayReturnCode_GatewayReturnCodeType] FOREIGN KEY ([IdGatewayReturnCodeType]) REFERENCES [dbo].[GatewayReturnCodeType] ([IdGatewayReturnCodeType]),
    CONSTRAINT [FK_GatewayReturnCode_Status] FOREIGN KEY ([IdStatusAction]) REFERENCES [dbo].[Status] ([IdStatus])
);


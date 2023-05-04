CREATE TABLE [dbo].[GatewayReturnCodeType] (
    [IdGatewayReturnCodeType] INT           NOT NULL,
    [ReturnCodeType]          NVARCHAR (32) NOT NULL,
    CONSTRAINT [PK_GatewayReturnCodeType] PRIMARY KEY CLUSTERED ([IdGatewayReturnCodeType] ASC) WITH (FILLFACTOR = 90)
);


CREATE TABLE [dbo].[GatewayBranch] (
    [IdGateway]         INT            NOT NULL,
    [IdBranch]          INT            NOT NULL,
    [GatewayBranchCode] NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]  DATETIME       NOT NULL,
    [EnterByIdUser]     INT            NOT NULL,
    CONSTRAINT [PK_GatewayBranch] PRIMARY KEY CLUSTERED ([IdGateway] ASC, [IdBranch] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_GatewayBranch_Branch] FOREIGN KEY ([IdBranch]) REFERENCES [dbo].[Branch] ([IdBranch]),
    CONSTRAINT [FK_GatewayBranch_Gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway])
);


GO
CREATE NONCLUSTERED INDEX [IX_GatewayBranch_IdBranch]
    ON [dbo].[GatewayBranch]([IdBranch] ASC)
    INCLUDE([IdGateway], [GatewayBranchCode], [DateOfLastChange], [EnterByIdUser]);


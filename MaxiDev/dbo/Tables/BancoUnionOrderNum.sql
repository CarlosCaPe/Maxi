CREATE TABLE [dbo].[BancoUnionOrderNum] (
    [IdOrder]    INT IDENTITY (1, 1) NOT NULL,
    [IdTransfer] INT NOT NULL,
    CONSTRAINT [PK_BancoUnionOrderNum] PRIMARY KEY CLUSTERED ([IdOrder] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_BancoUnionOrderNum_IdTransfer]
    ON [dbo].[BancoUnionOrderNum]([IdTransfer] ASC);


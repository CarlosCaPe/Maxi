CREATE TABLE [dbo].[AgentBalanceHelper] (
    [TypeOfMovement] NVARCHAR (MAX) NOT NULL,
    [IsDebit]        BIT            NULL,
    [IdOtherProduct] INT            NULL,
    CONSTRAINT [FK_AgentBalanceHelper_OtherProducts] FOREIGN KEY ([IdOtherProduct]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts])
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161207-173001]
    ON [dbo].[AgentBalanceHelper]([IsDebit] ASC)
    INCLUDE([TypeOfMovement]);


CREATE TABLE [dbo].[StateFee] (
    [IdStateFee]          INT            IDENTITY (1, 1) NOT NULL,
    [State]               NVARCHAR (MAX) NULL,
    [Tax]                 MONEY          NULL,
    [IdTransfer]          INT            NULL,
    [RejectedOrCancelled] BIT            NULL,
    CONSTRAINT [PK_StateFee] PRIMARY KEY CLUSTERED ([IdStateFee] ASC)
);


GO
CREATE NONCLUSTERED INDEX [inc_StateFee_IdTransfer]
    ON [dbo].[StateFee]([IdTransfer] ASC)
    INCLUDE([Tax]);


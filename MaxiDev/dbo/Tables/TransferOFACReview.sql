CREATE TABLE [dbo].[TransferOFACReview] (
    [IdTransferOFACReview] INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]           INT            NULL,
    [IdUserReview]         INT            NULL,
    [DateOfReview]         DATETIME       NULL,
    [IdOFACAction]         INT            NULL,
    [Note]                 NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TransferOFACReview] PRIMARY KEY CLUSTERED ([IdTransferOFACReview] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TransferOFACReview_Users1] FOREIGN KEY ([IdUserReview]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_TransferOFACReview_IdTransfer_IdUserReview]
    ON [dbo].[TransferOFACReview]([IdTransfer] ASC, [IdUserReview] ASC);


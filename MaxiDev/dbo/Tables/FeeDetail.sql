CREATE TABLE [dbo].[FeeDetail] (
    [IdFeeDetail]      INT      IDENTITY (1, 1) NOT NULL,
    [IdFee]            INT      NOT NULL,
    [FromAmount]       MONEY    NOT NULL,
    [ToAmount]         MONEY    NOT NULL,
    [Fee]              MONEY    NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    [EnterByIdUser]    INT      NOT NULL,
    [IsFeePercentage]  BIT      NOT NULL,
    CONSTRAINT [PK_FeeDetail] PRIMARY KEY CLUSTERED ([IdFeeDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_FeeDetail_Fee] FOREIGN KEY ([IdFee]) REFERENCES [dbo].[Fee] ([IdFee])
);


GO
CREATE NONCLUSTERED INDEX [IX_FeeDetail_IdFee]
    ON [dbo].[FeeDetail]([IdFee] ASC);


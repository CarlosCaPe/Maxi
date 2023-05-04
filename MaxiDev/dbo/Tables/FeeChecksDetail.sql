CREATE TABLE [dbo].[FeeChecksDetail] (
    [IdFeeChecksDetail] INT      IDENTITY (1, 1) NOT NULL,
    [IdFeeChecks]       INT      NOT NULL,
    [FromAmount]        MONEY    NOT NULL,
    [ToAmount]          MONEY    NOT NULL,
    [Fee]               MONEY    NOT NULL,
    [DateOfLastChange]  DATETIME NOT NULL,
    [EnterByIdUser]     INT      NOT NULL,
    [IsFeePercentage]   BIT      NOT NULL,
    CONSTRAINT [PK_FeeChecksDetail] PRIMARY KEY CLUSTERED ([IdFeeChecksDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_FeeChecksDetail_FeeChecks] FOREIGN KEY ([IdFeeChecks]) REFERENCES [dbo].[FeeChecks] ([IdFeeChecks])
);


GO
CREATE NONCLUSTERED INDEX [IX_FeeChecksDetail_IdFeeChecks]
    ON [dbo].[FeeChecksDetail]([IdFeeChecks] ASC)
    INCLUDE([FromAmount], [ToAmount], [Fee], [IsFeePercentage]);


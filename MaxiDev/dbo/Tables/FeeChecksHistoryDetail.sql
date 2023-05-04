CREATE TABLE [dbo].[FeeChecksHistoryDetail] (
    [IdFeeChecksHistoryDetail] INT      IDENTITY (1, 1) NOT NULL,
    [IdFeeChecksDetail]        INT      NOT NULL,
    [FromAmount]               MONEY    NOT NULL,
    [ToAmount]                 MONEY    NOT NULL,
    [Fee]                      MONEY    NOT NULL,
    [DateOfLastChange]         DATETIME NOT NULL,
    [EnterByIdUser]            INT      NOT NULL,
    [IsFeePercentage]          BIT      NOT NULL,
    CONSTRAINT [PK_FeeChecksHistoryDetail] PRIMARY KEY CLUSTERED ([IdFeeChecksHistoryDetail] ASC)
);


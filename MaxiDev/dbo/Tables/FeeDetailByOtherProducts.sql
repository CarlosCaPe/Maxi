CREATE TABLE [dbo].[FeeDetailByOtherProducts] (
    [IdFeeDetailByOtherProductsr] INT      IDENTITY (1, 1) NOT NULL,
    [IdFeeByOtherProducts]        INT      NOT NULL,
    [FromAmount]                  MONEY    NOT NULL,
    [ToAmount]                    MONEY    NOT NULL,
    [Fee]                         MONEY    NOT NULL,
    [DateOfLastChange]            DATETIME NOT NULL,
    [EnterByIdUser]               INT      NOT NULL,
    [IsFeePercentage]             BIT      NOT NULL
);


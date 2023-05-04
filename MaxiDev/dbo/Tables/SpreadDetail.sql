CREATE TABLE [dbo].[SpreadDetail] (
    [IdSpreadDetail]   INT      IDENTITY (1, 1) NOT NULL,
    [IdSpread]         INT      NOT NULL,
    [FromAmount]       MONEY    NOT NULL,
    [ToAmount]         MONEY    NOT NULL,
    [SpreadValue]      MONEY    NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    [EnterByIdUser]    INT      NOT NULL,
    CONSTRAINT [PK_SpreadDetail] PRIMARY KEY CLUSTERED ([IdSpreadDetail] ASC),
    CONSTRAINT [FK_SpreadDetail_Spread] FOREIGN KEY ([IdSpread]) REFERENCES [dbo].[Spread] ([IdSpread])
);


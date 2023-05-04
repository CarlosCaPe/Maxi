CREATE TABLE [dbo].[ScaleAmountBase] (
    [IdScaleAmountBase] INT   IDENTITY (1, 1) NOT NULL,
    [AmountBase]        MONEY NOT NULL,
    CONSTRAINT [PK_ScaleAmountBase] PRIMARY KEY CLUSTERED ([IdScaleAmountBase] ASC),
    CONSTRAINT [UQ_ScaleAmountBase] UNIQUE NONCLUSTERED ([AmountBase] ASC)
);


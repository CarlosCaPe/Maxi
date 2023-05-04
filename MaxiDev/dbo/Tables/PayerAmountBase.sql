CREATE TABLE [dbo].[PayerAmountBase] (
    [IdPayerAmountBase] INT IDENTITY (1, 1) NOT NULL,
    [IdPayerConfig]     INT NOT NULL,
    [IdScaleAmountBase] INT NOT NULL,
    [ValidateUSDAmount] BIT NOT NULL,
    [IsEnabled]         BIT NOT NULL,
    CONSTRAINT [PK_PayerAmountBase] PRIMARY KEY CLUSTERED ([IdPayerAmountBase] ASC),
    CONSTRAINT [FK_PayerAmountBase_PayerConfig] FOREIGN KEY ([IdPayerConfig]) REFERENCES [dbo].[PayerConfig] ([IdPayerConfig]),
    CONSTRAINT [FK_PayerAmountBase_ScaleAmountBase] FOREIGN KEY ([IdScaleAmountBase]) REFERENCES [dbo].[ScaleAmountBase] ([IdScaleAmountBase])
);


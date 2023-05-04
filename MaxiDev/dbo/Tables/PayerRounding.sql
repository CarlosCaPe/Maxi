CREATE TABLE [dbo].[PayerRounding] (
    [IdPayerRounding] BIGINT IDENTITY (1, 1) NOT NULL,
    [IdPayer]         INT    NOT NULL,
    [IdPaymentType]   INT    NOT NULL,
    [IdScaleRounding] INT    NOT NULL,
    [IsEnabled]       BIT    NOT NULL,
    CONSTRAINT [Pk_PayerRounding] PRIMARY KEY CLUSTERED ([IdPayerRounding] ASC)
);


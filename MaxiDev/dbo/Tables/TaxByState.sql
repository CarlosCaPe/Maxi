CREATE TABLE [dbo].[TaxByState] (
    [IdTax]        INT         IDENTITY (1, 1) NOT NULL,
    [StateCode]    VARCHAR (3) NOT NULL,
    [FromAmount]   MONEY       NOT NULL,
    [ToAmount]     MONEY       NULL,
    [IsPercentage] BIT         NOT NULL,
    [Amount]       MONEY       NOT NULL,
    CONSTRAINT [PK_TaxByState] PRIMARY KEY CLUSTERED ([IdTax] ASC) WITH (FILLFACTOR = 90)
);


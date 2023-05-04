CREATE TABLE [dbo].[RefExRate] (
    [IdRefExRate]       INT      IDENTITY (1, 1) NOT NULL,
    [IdCountryCurrency] INT      NOT NULL,
    [RefExRate]         MONEY    NOT NULL,
    [Active]            BIT      NOT NULL,
    [DateOfLastChange]  DATETIME NOT NULL,
    [EnterByIdUser]     INT      NOT NULL,
    [IdGateway]         INT      NULL,
    [IdPayer]           INT      NULL,
    CONSTRAINT [PK_RefExRate] PRIMARY KEY CLUSTERED ([IdRefExRate] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_RefExRate_CountryCurrency] FOREIGN KEY ([IdCountryCurrency]) REFERENCES [dbo].[CountryCurrency] ([IdCountryCurrency])
);


GO
CREATE NONCLUSTERED INDEX [idxRefExRateIdCountryCurrencyActive]
    ON [dbo].[RefExRate]([IdCountryCurrency] ASC, [IdGateway] ASC, [IdPayer] ASC, [Active] ASC)
    INCLUDE([IdRefExRate], [RefExRate], [DateOfLastChange], [EnterByIdUser]) WITH (FILLFACTOR = 90);


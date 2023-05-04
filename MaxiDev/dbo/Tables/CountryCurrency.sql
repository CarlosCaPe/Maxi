CREATE TABLE [dbo].[CountryCurrency] (
    [IdCountryCurrency] INT      IDENTITY (1, 1) NOT NULL,
    [IdCountry]         INT      NOT NULL,
    [IdCurrency]        INT      NOT NULL,
    [DateOfLastChange]  DATETIME NOT NULL,
    [EnterByIdUser]     INT      NOT NULL,
    CONSTRAINT [PK_CountryCurrency] PRIMARY KEY CLUSTERED ([IdCountryCurrency] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CountryCurrency_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_CountryCurrency_Currency] FOREIGN KEY ([IdCurrency]) REFERENCES [dbo].[Currency] ([IdCurrency]),
    CONSTRAINT [FK_CountryCurrency_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


CREATE TABLE [dbo].[CountryPureMinutes] (
    [IdCountryPureMinutes] INT            NOT NULL,
    [CountryName]          NVARCHAR (MAX) NOT NULL,
    [IdGenericStatus]      INT            NULL,
    CONSTRAINT [PK_CountryPureMinutes] PRIMARY KEY CLUSTERED ([IdCountryPureMinutes] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CountryPureMinutes_AgentBankDeposit] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);


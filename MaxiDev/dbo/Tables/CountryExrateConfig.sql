CREATE TABLE [dbo].[CountryExrateConfig] (
    [IdCountryExrateConfig] INT      IDENTITY (1, 1) NOT NULL,
    [IdCountry]             INT      NOT NULL,
    [IdGateway]             INT      NOT NULL,
    [UseRefExrate]          BIT      NOT NULL,
    [DateOfLastChange]      DATETIME NOT NULL,
    [EnterByIdUser]         INT      NOT NULL,
    [IdGenericStatus]       INT      NULL,
    CONSTRAINT [PK_CountryExrateConfig] PRIMARY KEY CLUSTERED ([IdCountryExrateConfig] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CountryExrateConfig_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_CountryExrateConfig_gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_CountryExrateConfig_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_CountryExrateConfig_Users1] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


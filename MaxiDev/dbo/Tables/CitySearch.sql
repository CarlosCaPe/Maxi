CREATE TABLE [dbo].[CitySearch] (
    [IdCitySearch]   INT           IDENTITY (1, 1) NOT NULL,
    [IdCity]         INT           NULL,
    [IdState]        INT           NULL,
    [CityNameRaw]    VARCHAR (500) NOT NULL,
    [CityNameAppend] VARCHAR (500) NOT NULL,
    [CityNameClean]  VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_CitySearch] PRIMARY KEY CLUSTERED ([IdCitySearch] ASC),
    CONSTRAINT [FK_CitySearch_City] FOREIGN KEY ([IdCity]) REFERENCES [dbo].[City] ([IdCity]),
    CONSTRAINT [FK_CitySearch_State] FOREIGN KEY ([IdState]) REFERENCES [dbo].[State] ([IdState])
);


GO
CREATE NONCLUSTERED INDEX [IX_CitySearch_CityNameAppend]
    ON [dbo].[CitySearch]([IdCity] ASC, [CityNameAppend] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CitySearch_CityNameClean]
    ON [dbo].[CitySearch]([IdCity] ASC, [CityNameClean] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CitySearch_CityNameRaw]
    ON [dbo].[CitySearch]([IdCity] ASC, [CityNameRaw] ASC);


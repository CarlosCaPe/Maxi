CREATE TABLE [dbo].[CountryBirth] (
    [IdCountryBirth] INT            IDENTITY (1, 1) NOT NULL,
    [Fips]           VARCHAR (2)    NOT NULL,
    [Iso]            VARCHAR (2)    NOT NULL,
    [Tld]            VARCHAR (3)    NOT NULL,
    [Country]        NVARCHAR (MAX) DEFAULT ('') NOT NULL,
    [CountryEs]      NVARCHAR (MAX) DEFAULT ('') NOT NULL,
    [DateLastChange] DATETIME       DEFAULT (getdate()) NOT NULL,
    [EnterByIdUser]  INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IdCountryBirth] ASC),
    FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


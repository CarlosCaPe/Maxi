CREATE TABLE [DTOne].[Country] (
    [IdCountry]        INT            IDENTITY (1, 1) NOT NULL,
    [CountryName]      NCHAR (150)    NOT NULL,
    [DateOfCreation]   DATETIME       NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [PhoneCountryCode] NVARCHAR (MAX) NULL,
    [CountryCode]      NVARCHAR (50)  NULL,
    [IdGenericStatus]  INT            NULL,
    CONSTRAINT [PK_DTOneCountry] PRIMARY KEY CLUSTERED ([IdCountry] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_DTOneCountry_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


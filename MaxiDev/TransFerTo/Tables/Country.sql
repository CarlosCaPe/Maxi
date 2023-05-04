CREATE TABLE [TransFerTo].[Country] (
    [IdCountry]        INT            IDENTITY (1, 1) NOT NULL,
    [CountryName]      NCHAR (150)    NOT NULL,
    [DateOfCreation]   DATETIME       NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [IdCountryTTo]     INT            NULL,
    [PhoneCountryCode] NVARCHAR (MAX) NULL,
    [CountryCode]      NVARCHAR (3)   NULL,
    [IdGenericStatus]  INT            NULL,
    CONSTRAINT [PK_TransferTToCountry] PRIMARY KEY CLUSTERED ([IdCountry] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TToCountry_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


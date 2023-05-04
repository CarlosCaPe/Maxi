CREATE TABLE [dbo].[CustomerIdentifTypeByCountry] (
    [IdIdentificationByCountry] INT IDENTITY (1, 1) NOT NULL,
    [IdDocument]                INT NOT NULL,
    [IdCountry]                 INT NOT NULL,
    CONSTRAINT [PK_IdentificationByCountry] PRIMARY KEY CLUSTERED ([IdIdentificationByCountry] ASC) WITH (FILLFACTOR = 90)
);


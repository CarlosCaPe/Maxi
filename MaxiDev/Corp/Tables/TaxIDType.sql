CREATE TABLE [Corp].[TaxIDType] (
    [IdTaxIDType]      INT           IDENTITY (1, 1) NOT NULL,
    [Name]             VARCHAR (100) NULL,
    [DateOfCreation]   DATETIME      NULL,
    [DateOfLastChange] DATETIME      NULL,
    CONSTRAINT [PK_TaxIdType] PRIMARY KEY CLUSTERED ([IdTaxIDType] ASC)
);


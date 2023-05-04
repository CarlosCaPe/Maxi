CREATE TABLE [dbo].[PontualAvailableBanks] (
    [IdAvailableBanks] INT            IDENTITY (1, 1) NOT NULL,
    [BankName]         NVARCHAR (250) NULL,
    [BankID]           INT            NULL,
    [DateOfLastChange] DATETIME       NULL,
    [LocationCode]     NVARCHAR (50)  NULL,
    [CountryBankCode]  NVARCHAR (50)  NULL,
    CONSTRAINT [PK_PontualAvailableBanks] PRIMARY KEY CLUSTERED ([IdAvailableBanks] ASC)
);


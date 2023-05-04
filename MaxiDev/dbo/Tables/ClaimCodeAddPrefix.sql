CREATE TABLE [dbo].[ClaimCodeAddPrefix] (
    [ClaimCodeAddPrefixId] INT IDENTITY (1, 1) NOT NULL,
    [IdPayer]              INT NOT NULL,
    CONSTRAINT [PK_ClaimCodeAddPrefix] PRIMARY KEY CLUSTERED ([ClaimCodeAddPrefixId] ASC)
);


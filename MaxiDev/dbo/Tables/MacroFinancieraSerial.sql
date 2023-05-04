CREATE TABLE [dbo].[MacroFinancieraSerial] (
    [IdMacroFinanciera] INT IDENTITY (1, 1) NOT NULL,
    [IdTransfer]        INT NOT NULL,
    CONSTRAINT [PK_MacroFinancieraSerial] PRIMARY KEY CLUSTERED ([IdMacroFinanciera] ASC) WITH (FILLFACTOR = 90)
);


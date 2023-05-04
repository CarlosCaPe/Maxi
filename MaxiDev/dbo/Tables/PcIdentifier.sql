CREATE TABLE [dbo].[PcIdentifier] (
    [IdPcIdentifier]     INT            IDENTITY (1, 1) NOT NULL,
    [MachineDescription] NVARCHAR (MAX) NOT NULL,
    [Identifier]         NVARCHAR (MAX) NOT NULL,
    [SerialNumber]       VARCHAR (MAX)  NULL,
    [MachineName]        VARCHAR (MAX)  NULL,
    [ScannerType]        VARCHAR (50)   NULL,
    [MoneyOrderPrinter]  VARCHAR (200)  NULL,
    CONSTRAINT [PK_PcIdentifier] PRIMARY KEY CLUSTERED ([IdPcIdentifier] ASC) WITH (FILLFACTOR = 90)
);


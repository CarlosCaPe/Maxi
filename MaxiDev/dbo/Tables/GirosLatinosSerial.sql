CREATE TABLE [dbo].[GirosLatinosSerial] (
    [IdGirosLatinos] INT IDENTITY (1, 1) NOT NULL,
    [IdTransfer]     INT NOT NULL,
    CONSTRAINT [PK_GirosLatinosSerial] PRIMARY KEY CLUSTERED ([IdGirosLatinos] ASC) WITH (FILLFACTOR = 90)
);


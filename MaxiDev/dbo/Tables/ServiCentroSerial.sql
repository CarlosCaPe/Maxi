CREATE TABLE [dbo].[ServiCentroSerial] (
    [IdServiCentro] INT IDENTITY (1, 1) NOT NULL,
    [IdTransfer]    INT NOT NULL,
    CONSTRAINT [PK_ServiCentroSerial] PRIMARY KEY CLUSTERED ([IdServiCentro] ASC) WITH (FILLFACTOR = 90)
);


CREATE TABLE [dbo].[ModuloMaster] (
    [IdModuloMaster]  INT           IDENTITY (1, 1) NOT NULL,
    [Description]     VARCHAR (100) NOT NULL,
    [IsFilterByAgent] BIT           NOT NULL,
    [IdOtherProducts] INT           NULL,
    [IdChekcModulo]   INT           NULL,
    CONSTRAINT [PK_ModuloMaster] PRIMARY KEY CLUSTERED ([IdModuloMaster] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ModuloMaster_OtherProducts] FOREIGN KEY ([IdOtherProducts]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts])
);


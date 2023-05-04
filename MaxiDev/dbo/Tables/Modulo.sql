CREATE TABLE [dbo].[Modulo] (
    [IdModule]       INT            NOT NULL,
    [IdApplication]  INT            NOT NULL,
    [Name]           VARCHAR (50)   NOT NULL,
    [Description]    VARCHAR (100)  NOT NULL,
    [IdModuloMaster] INT            NOT NULL,
    [DescriptionES]  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Modulo] PRIMARY KEY CLUSTERED ([IdModule] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Modulo_Application] FOREIGN KEY ([IdApplication]) REFERENCES [dbo].[Application] ([IdApplication]),
    CONSTRAINT [FK_Modulo_ModuloMaster] FOREIGN KEY ([IdModuloMaster]) REFERENCES [dbo].[ModuloMaster] ([IdModuloMaster])
);


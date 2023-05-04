CREATE TABLE [dbo].[FD_EnviromentConfigs] (
    [IdFDEnviromentConfigs] INT            IDENTITY (1, 1) NOT NULL,
    [IdFDEnviroment]        INT            NOT NULL,
    [Key]                   NVARCHAR (80)  NOT NULL,
    [Value]                 NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_FDEnviromentConfigs] PRIMARY KEY CLUSTERED ([IdFDEnviromentConfigs] ASC),
    CONSTRAINT [FK_FDEnviromentConfigs_FDEnviroment] FOREIGN KEY ([IdFDEnviroment]) REFERENCES [dbo].[FD_Enviroment] ([Id]),
    CONSTRAINT [UQ_FDEnviromentConfigs] UNIQUE NONCLUSTERED ([IdFDEnviroment] ASC, [Key] ASC)
);


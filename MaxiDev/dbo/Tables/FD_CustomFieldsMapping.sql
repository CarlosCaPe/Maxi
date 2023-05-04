CREATE TABLE [dbo].[FD_CustomFieldsMapping] (
    [IdCustomFieldsMapping] INT            IDENTITY (1, 1) NOT NULL,
    [IdFDEntity]            INT            NOT NULL,
    [Field]                 NVARCHAR (80)  NOT NULL,
    [Value]                 NVARCHAR (200) NOT NULL,
    [IdEnviroment]          INT            NULL,
    CONSTRAINT [PK_FDCustomFieldsMapping] PRIMARY KEY CLUSTERED ([IdCustomFieldsMapping] ASC),
    FOREIGN KEY ([IdEnviroment]) REFERENCES [dbo].[FD_Enviroment] ([Id]),
    CONSTRAINT [FK_FDCustomFieldsMapping_IdFDEntity] FOREIGN KEY ([IdFDEntity]) REFERENCES [dbo].[FD_Entity] ([IdEntity])
);


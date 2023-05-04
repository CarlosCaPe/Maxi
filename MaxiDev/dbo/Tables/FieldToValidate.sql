CREATE TABLE [dbo].[FieldToValidate] (
    [IdFieldToVAlidate]  INT           IDENTITY (1, 1) NOT NULL,
    [IdEntityToValidate] INT           NOT NULL,
    [Name]               VARCHAR (50)  NOT NULL,
    [Description]        VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_FieldToValidate] PRIMARY KEY CLUSTERED ([IdFieldToVAlidate] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_FieldToValidate_EntityToValidate] FOREIGN KEY ([IdEntityToValidate]) REFERENCES [dbo].[EntityToValidate] ([IdEntityToValidate])
);


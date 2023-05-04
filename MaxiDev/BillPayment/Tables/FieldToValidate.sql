CREATE TABLE [BillPayment].[FieldToValidate] (
    [IdFieldToVAlidate]  INT           IDENTITY (1, 1) NOT NULL,
    [IdEntityToValidate] INT           NOT NULL,
    [Name]               VARCHAR (50)  NOT NULL,
    [Description]        VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_FieldToValidate] PRIMARY KEY CLUSTERED ([IdFieldToVAlidate] ASC),
    CONSTRAINT [FK_FieldToValidate_EntityToValidate] FOREIGN KEY ([IdEntityToValidate]) REFERENCES [BillPayment].[EntityToValidate] ([IdEntityToValidate])
);


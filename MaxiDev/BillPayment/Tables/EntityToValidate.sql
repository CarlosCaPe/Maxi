CREATE TABLE [BillPayment].[EntityToValidate] (
    [IdEntityToValidate] INT           NOT NULL,
    [Name]               VARCHAR (50)  NOT NULL,
    [Description]        VARCHAR (500) NOT NULL,
    [IsAllowedToEdit]    BIT           NOT NULL,
    CONSTRAINT [PK_EntityToValidate_1] PRIMARY KEY CLUSTERED ([IdEntityToValidate] ASC)
);


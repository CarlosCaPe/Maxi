CREATE TABLE [BillPayment].[Validator] (
    [IdValidator]   INT           NOT NULL,
    [ValidatorName] VARCHAR (50)  NOT NULL,
    [Description]   VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_Validator] PRIMARY KEY CLUSTERED ([IdValidator] ASC)
);


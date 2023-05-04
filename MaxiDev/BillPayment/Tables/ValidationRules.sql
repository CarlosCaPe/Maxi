CREATE TABLE [BillPayment].[ValidationRules] (
    [IdValidationRule]        INT           IDENTITY (1, 1) NOT NULL,
    [IdEntityToValidate]      INT           NOT NULL,
    [IdValidator]             INT           NOT NULL,
    [IdStateConfig]           INT           NULL,
    [Field]                   VARCHAR (50)  NOT NULL,
    [ErrorMessageES]          VARCHAR (500) NOT NULL,
    [ErrorMessageUS]          VARCHAR (500) NOT NULL,
    [OrderByEntityToValidate] INT           NOT NULL,
    [IdGenericStatus]         INT           NOT NULL,
    [IsAllowedToEdit]         BIT           DEFAULT ((1)) NOT NULL,
    [IdUser]                  INT           NOT NULL,
    [LastChange]              DATETIME      NULL,
    CONSTRAINT [PK_ValidationRules] PRIMARY KEY CLUSTERED ([IdValidationRule] ASC),
    CONSTRAINT [FK_EntityToValidateState_EntityToValidate] FOREIGN KEY ([IdEntityToValidate]) REFERENCES [BillPayment].[EntityToValidate] ([IdEntityToValidate]),
    CONSTRAINT [FK_EntityToValidateState_StateConfig] FOREIGN KEY ([IdStateConfig]) REFERENCES [dbo].[State] ([IdState]),
    CONSTRAINT [FK_ValidationRules_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_ValidationRules_Validator] FOREIGN KEY ([IdValidator]) REFERENCES [BillPayment].[Validator] ([IdValidator])
);


CREATE TABLE [dbo].[ValidationRules] (
    [IdValidationRule]        INT           IDENTITY (1, 1) NOT NULL,
    [IdEntityToValidate]      INT           NOT NULL,
    [IdValidator]             INT           NOT NULL,
    [IdPayerConfig]           INT           NULL,
    [Field]                   VARCHAR (50)  NOT NULL,
    [ErrorMessageES]          VARCHAR (500) NOT NULL,
    [ErrorMessageUS]          VARCHAR (500) NOT NULL,
    [OrderByEntityToValidate] INT           NOT NULL,
    [IdGenericStatus]         INT           NOT NULL,
    [IsAllowedToEdit]         BIT           DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_ValidationRules] PRIMARY KEY CLUSTERED ([IdValidationRule] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_EntityToValidatePayer_EntityToValidate] FOREIGN KEY ([IdEntityToValidate]) REFERENCES [dbo].[EntityToValidate] ([IdEntityToValidate]),
    CONSTRAINT [FK_EntityToValidatePayer_PayerConfig] FOREIGN KEY ([IdPayerConfig]) REFERENCES [dbo].[PayerConfig] ([IdPayerConfig]),
    CONSTRAINT [FK_ValidationRules_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_ValidationRules_Validator] FOREIGN KEY ([IdValidator]) REFERENCES [dbo].[Validator] ([IdValidator])
);


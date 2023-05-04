CREATE TABLE [dbo].[CustomerBlackListRule] (
    [IdCustomerBlackListRule] INT            IDENTITY (1, 1) NOT NULL,
    [Alias]                   NVARCHAR (MAX) NULL,
    [RuleNameInSpanish]       NVARCHAR (MAX) NULL,
    [RuleNameInEnglish]       NVARCHAR (MAX) NULL,
    [IdCBLaction]             INT            NULL,
    [MessageInSpanish]        NVARCHAR (MAX) NULL,
    [MessageInEnglish]        NVARCHAR (MAX) NULL,
    [IdGenericStatus]         INT            NULL,
    [DateOfLastChange]        DATETIME       NULL,
    [EnterByIdUser]           INT            NULL,
    CONSTRAINT [PK_CustomerBlackListRule] PRIMARY KEY CLUSTERED ([IdCustomerBlackListRule] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CustomerBlackListeRule_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_CustomerBlackListeRule_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


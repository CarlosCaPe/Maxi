CREATE TABLE [dbo].[WhiteListIssuerChecks] (
    [IdWhiteListIssuerChecks] INT           IDENTITY (1, 1) NOT NULL,
    [IdIssuerCheck]           INT           NOT NULL,
    [DateInToList]            DATETIME      NOT NULL,
    [DateOutFromList]         DATETIME      NULL,
    [IdUserCreater]           INT           NOT NULL,
    [IdUserDeleter]           INT           NULL,
    [NoteInToList]            VARCHAR (500) NULL,
    [NoteOutFromList]         VARCHAR (500) NULL,
    [IdGenericStatus]         INT           NOT NULL,
    CONSTRAINT [PK_WhiteListIssuerChecks] PRIMARY KEY CLUSTERED ([IdWhiteListIssuerChecks] ASC),
    CONSTRAINT [FK_WhiteListIssuerChecks_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_WhiteListIssuerChecks_Issuer] FOREIGN KEY ([IdIssuerCheck]) REFERENCES [dbo].[IssuerChecks] ([IdIssuer]),
    CONSTRAINT [FK_WhiteListIssuerChecks_UserCreater] FOREIGN KEY ([IdUserCreater]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_WhiteListIssuerChecks_UserDeleter] FOREIGN KEY ([IdUserDeleter]) REFERENCES [dbo].[Users] ([IdUser])
);


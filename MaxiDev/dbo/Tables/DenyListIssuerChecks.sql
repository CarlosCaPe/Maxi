CREATE TABLE [dbo].[DenyListIssuerChecks] (
    [IdDenyListIssuerCheck] INT             IDENTITY (1, 1) NOT NULL,
    [IdIssuerCheck]         INT             NOT NULL,
    [DateInToList]          DATETIME        NOT NULL,
    [DateOutFromList]       DATETIME        NULL,
    [IdUserCreater]         INT             NOT NULL,
    [IdUserDeleter]         INT             NULL,
    [NoteInToList]          NVARCHAR (1000) NOT NULL,
    [NoteOutFromList]       NVARCHAR (1000) NULL,
    [IdGenericStatus]       INT             NOT NULL,
    [EnterByIdUser]         INT             NULL,
    [DateOfLastChange]      DATETIME        NULL,
    CONSTRAINT [PK_DenyListIssuerChecks] PRIMARY KEY CLUSTERED ([IdDenyListIssuerCheck] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_DenyListIssuerChecks_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_DenyListIssuerChecks_IssuerChecks] FOREIGN KEY ([IdIssuerCheck]) REFERENCES [dbo].[IssuerChecks] ([IdIssuer])
);


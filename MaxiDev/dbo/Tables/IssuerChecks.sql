CREATE TABLE [dbo].[IssuerChecks] (
    [IdIssuer]         INT           IDENTITY (1, 1) NOT NULL,
    [Name]             VARCHAR (MAX) NOT NULL,
    [RoutingNumber]    VARCHAR (100) NOT NULL,
    [AccountNumber]    VARCHAR (100) NOT NULL,
    [DateOfCreation]   DATETIME      NULL,
    [DateOfLastChange] DATETIME      NULL,
    [EnteredByIdUser]  INT           NOT NULL,
    [PhoneNumber]      NVARCHAR (30) NULL,
    CONSTRAINT [PK_IssuerChecks] PRIMARY KEY CLUSTERED ([IdIssuer] ASC),
    CONSTRAINT [FK_IssuerChecks_Users] FOREIGN KEY ([EnteredByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_IssuerChecks_RoutingNumber_AccountNumber]
    ON [dbo].[IssuerChecks]([RoutingNumber] ASC, [AccountNumber] ASC);


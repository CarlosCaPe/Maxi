CREATE TABLE [dbo].[DenyListIssuerCheckActions] (
    [IdDenyListIssuerCheckAction] INT            IDENTITY (1, 1) NOT NULL,
    [IdDenyListIssuerCheck]       INT            NOT NULL,
    [IdKYCAction]                 INT            NOT NULL,
    [MessageInEnglish]            NVARCHAR (MAX) NOT NULL,
    [MessageInSpanish]            NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_DenyListIssuerCheckActions] PRIMARY KEY CLUSTERED ([IdDenyListIssuerCheckAction] ASC),
    CONSTRAINT [FK_DenyListIssuerCheckActions_DenyListIssuerChecks] FOREIGN KEY ([IdDenyListIssuerCheck]) REFERENCES [dbo].[DenyListIssuerChecks] ([IdDenyListIssuerCheck]),
    CONSTRAINT [FK_DenyListIssuerCheckActions_KYCAction] FOREIGN KEY ([IdKYCAction]) REFERENCES [dbo].[KYCAction] ([IdKYCAction])
);


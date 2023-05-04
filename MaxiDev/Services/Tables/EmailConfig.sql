CREATE TABLE [Services].[EmailConfig] (
    [IdEmailConfig]         INT            IDENTITY (1, 1) NOT NULL,
    [Host]                  NVARCHAR (MAX) NOT NULL,
    [Port]                  INT            NOT NULL,
    [EnableSSL]             BIT            NOT NULL,
    [UseDefaultCredentials] BIT            NOT NULL,
    [UserName]              NVARCHAR (MAX) NOT NULL,
    [Password]              NVARCHAR (MAX) NOT NULL,
    [Alias]                 NVARCHAR (MAX) NOT NULL,
    [DateOfCreation]        DATETIME       NOT NULL,
    [DateOfLastChange]      DATETIME       NOT NULL,
    [EnterByIdUser]         INT            NOT NULL,
    [IdGenericStatus]       INT            NOT NULL,
    [IdService]             INT            NOT NULL,
    CONSTRAINT [PK_EmailConfig] PRIMARY KEY CLUSTERED ([IdEmailConfig] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_EmailConfig_OPStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_EmailConfig_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


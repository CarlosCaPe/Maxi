CREATE TABLE [Services].[Email] (
    [IdEmail]          INT            IDENTITY (1, 1) NOT NULL,
    [Code]             NVARCHAR (128) NOT NULL,
    [Email]            NVARCHAR (MAX) NOT NULL,
    [DateOfCreation]   DATETIME       NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [IdGenericStatus]  INT            NOT NULL,
    CONSTRAINT [PK_IdEmail] PRIMARY KEY CLUSTERED ([IdEmail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [Email_ServiceConfiguration] FOREIGN KEY ([Code]) REFERENCES [Services].[ServiceConfiguration] ([Code]),
    CONSTRAINT [FK_Email_OPStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_Email_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


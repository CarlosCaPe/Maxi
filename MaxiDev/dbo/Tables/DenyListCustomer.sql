CREATE TABLE [dbo].[DenyListCustomer] (
    [IdDenyListCustomer] INT             IDENTITY (1, 1) NOT NULL,
    [IdCustomer]         INT             NOT NULL,
    [DateInToList]       DATETIME        NOT NULL,
    [DateOutFromList]    DATETIME        NULL,
    [IdUserCreater]      INT             NOT NULL,
    [IdUserDeleter]      INT             NULL,
    [NoteInToList]       NVARCHAR (1000) NOT NULL,
    [NoteOutFromList]    NVARCHAR (1000) NULL,
    [IdGenericStatus]    INT             NOT NULL,
    [EnterByIdUser]      INT             NULL,
    [DateOfLastChange]   DATETIME        NULL,
    CONSTRAINT [PK_DenyListCustomer] PRIMARY KEY CLUSTERED ([IdDenyListCustomer] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_DenyListCustomer_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_DenyListCustomer_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);


GO
CREATE NONCLUSTERED INDEX [DenyListCustomer_GenericStatusIdCustomer]
    ON [dbo].[DenyListCustomer]([IdGenericStatus] ASC)
    INCLUDE([IdDenyListCustomer], [IdCustomer]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ix_DenyListCustomer_IdCustomer_IdGenericStatus_includes]
    ON [dbo].[DenyListCustomer]([IdCustomer] ASC, [IdGenericStatus] ASC)
    INCLUDE([IdDenyListCustomer]);


CREATE TABLE [dbo].[CustomerBlackList] (
    [IdCustomerBlackList]     INT             IDENTITY (1, 1) NOT NULL,
    [IdCustomerBlackListRule] INT             NOT NULL,
    [IdCustomer]              INT             NOT NULL,
    [CustomerName]            NVARCHAR (MAX)  NULL,
    [CustomerFirstLastName]   NVARCHAR (MAX)  NULL,
    [CustomerSecondLastName]  NVARCHAR (MAX)  NULL,
    [CustomerFullName]        NVARCHAR (2000) NULL,
    [DateOfCreation]          DATETIME        NULL,
    [DateOfLastChange]        DATETIME        NULL,
    [EnterByIdUser]           INT             NULL,
    [IdGenericStatus]         INT             NULL,
    [Notes]                   NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_CustomerBlackList] PRIMARY KEY CLUSTERED ([IdCustomerBlackList] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CustomerBlackList_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_CustomerBlackList_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ix_CustomerBlackList_IdCustomer_IdGenericStatus]
    ON [dbo].[CustomerBlackList]([IdCustomer] ASC, [IdGenericStatus] ASC);


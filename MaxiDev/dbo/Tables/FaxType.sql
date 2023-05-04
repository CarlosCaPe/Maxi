CREATE TABLE [dbo].[FaxType] (
    [IdFaxType]        INT            IDENTITY (1, 1) NOT NULL,
    [FaxTypeName]      NVARCHAR (MAX) NOT NULL,
    [ExpireDays]       INT            NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [IdGenericStatus]  INT            NOT NULL,
    CONSTRAINT [PK_FaxType] PRIMARY KEY CLUSTERED ([IdFaxType] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_FaxType_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_FaxType_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


CREATE TABLE [CheckConfig].[Bank] (
    [IdBank]           INT            IDENTITY (1, 1) NOT NULL,
    [BankName]         NVARCHAR (MAX) NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [DateOfLastChange] DATETIME       DEFAULT (getdate()) NOT NULL,
    [IdGenericStatus]  INT            NOT NULL,
    CONSTRAINT [PK_CCBank] PRIMARY KEY CLUSTERED ([IdBank] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Bank_genericstatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_Bank_users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


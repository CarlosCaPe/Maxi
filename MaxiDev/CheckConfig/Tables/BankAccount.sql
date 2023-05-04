CREATE TABLE [CheckConfig].[BankAccount] (
    [IdBankAccount]        INT            IDENTITY (1, 1) NOT NULL,
    [IdBank]               INT            NOT NULL,
    [BankAccountName]      NVARCHAR (MAX) NOT NULL,
    [BankAccountCode]      NVARCHAR (MAX) NOT NULL,
    [EnterByIdUser]        INT            NOT NULL,
    [DateOfLastChange]     DATETIME       DEFAULT (getdate()) NOT NULL,
    [IdGenericStatus]      INT            NOT NULL,
    [IdState]              INT            NULL,
    [IsEnableOtherAccount] BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CCBankAccount] PRIMARY KEY CLUSTERED ([IdBankAccount] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_BankAccount_Bank] FOREIGN KEY ([IdBank]) REFERENCES [CheckConfig].[Bank] ([IdBank]),
    CONSTRAINT [FK_BankAccount_genericstatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_BankAccount_State] FOREIGN KEY ([IdState]) REFERENCES [dbo].[State] ([IdState]),
    CONSTRAINT [FK_BankAccount_users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


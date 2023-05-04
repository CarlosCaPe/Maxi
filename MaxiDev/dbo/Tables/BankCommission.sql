CREATE TABLE [dbo].[BankCommission] (
    [IdBankCommission]     INT        IDENTITY (1, 1) NOT NULL,
    [DateOfLastChange]     DATETIME   NOT NULL,
    [DateOfBankCommission] DATETIME   NOT NULL,
    [EnterByIdUser]        INT        NOT NULL,
    [FactorOld]            FLOAT (53) NOT NULL,
    [FactorNew]            FLOAT (53) NOT NULL,
    [Active]               BIT        NOT NULL,
    CONSTRAINT [PK_BankCommission] PRIMARY KEY CLUSTERED ([IdBankCommission] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_BankCommission_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


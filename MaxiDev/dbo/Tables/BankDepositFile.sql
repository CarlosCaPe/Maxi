CREATE TABLE [dbo].[BankDepositFile] (
    [IdBankDepositFile]  INT           IDENTITY (1, 1) NOT NULL,
    [IdAgentBankDeposit] INT           NOT NULL,
    [FileDate]           DATETIME      NOT NULL,
    [FileName]           VARCHAR (200) NOT NULL,
    [Processed]          BIT           NOT NULL,
    [CreationDate]       DATETIME      NOT NULL,
    [IdUser]             INT           NOT NULL,
    CONSTRAINT [PK_IdBankDepositFile] PRIMARY KEY CLUSTERED ([IdBankDepositFile] ASC),
    CONSTRAINT [FK_BankDepositFile_AgentBankDeposit] FOREIGN KEY ([IdAgentBankDeposit]) REFERENCES [dbo].[AgentBankDeposit] ([IdAgentBankDeposit]),
    CONSTRAINT [FK_BankDepositFile_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


CREATE TABLE [dbo].[AgentBankDeposit] (
    [IdAgentBankDeposit] INT            IDENTITY (1, 1) NOT NULL,
    [BankName]           NVARCHAR (MAX) NULL,
    [AccountNumber]      NVARCHAR (MAX) NULL,
    [DateOfLastChange]   DATETIME       NULL,
    [EnterByIdUser]      INT            NULL,
    [IdGenericStatus]    INT            NULL,
    [IsTablet]           BIT            DEFAULT ((0)) NOT NULL,
    [SubAccountRequired] BIT            DEFAULT (CONVERT([bit],(0))) NOT NULL,
    CONSTRAINT [PK_AgentBankDeposit] PRIMARY KEY CLUSTERED ([IdAgentBankDeposit] ASC) WITH (FILLFACTOR = 90)
);


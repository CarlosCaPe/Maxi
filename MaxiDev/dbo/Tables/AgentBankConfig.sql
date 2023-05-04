CREATE TABLE [dbo].[AgentBankConfig] (
    [IdConfig]        INT IDENTITY (1, 1) NOT NULL,
    [IdAgent]         INT NULL,
    [IdBank]          INT NULL,
    [IdAccount]       INT NULL,
    [EnteredByIdUser] INT NULL,
    PRIMARY KEY CLUSTERED ([IdConfig] ASC)
);


CREATE TABLE [dbo].[AgentCreditSuggest] (
    [IdAgentCreditSuggest] INT             IDENTITY (1, 1) NOT NULL,
    [IdAgent]              INT             NOT NULL,
    [CreditLimit]          MONEY           NULL,
    [Margin]               MONEY           NULL,
    [Suggested]            MONEY           NULL,
    [IsApproved]           BIT             NULL,
    [CreationDate]         DATETIME        NULL,
    [DateOfLastChange]     DATETIME        NULL,
    [EnterByIdUser]        INT             NOT NULL,
    [Coments]              NVARCHAR (2000) NULL,
    CONSTRAINT [PK_CreditSuggest] PRIMARY KEY CLUSTERED ([IdAgentCreditSuggest] ASC),
    CONSTRAINT [FK_AgentCreditSuggest_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCreditSuggest_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


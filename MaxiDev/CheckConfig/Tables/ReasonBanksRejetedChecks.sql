CREATE TABLE [CheckConfig].[ReasonBanksRejetedChecks] (
    [IdReason]        INT           IDENTITY (1, 1) NOT NULL,
    [MaxiReason]      VARCHAR (MAX) NULL,
    [IdBank]          INT           NULL,
    [BankReason]      VARCHAR (MAX) NULL,
    [ReturnReason_ID] INT           NULL
);


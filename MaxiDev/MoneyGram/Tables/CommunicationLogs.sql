CREATE TABLE [MoneyGram].[CommunicationLogs] (
    [IdComunicationLogs] INT           IDENTITY (1, 1) NOT NULL,
    [IdPreTransfer]      INT           NOT NULL,
    [IdTransfer]         INT           NULL,
    [Action]             VARCHAR (200) NOT NULL,
    [Request]            XML           NOT NULL,
    [Response]           XML           NOT NULL,
    [CreationDate]       DATETIME      NOT NULL,
    [IdUser]             INT           NOT NULL,
    CONSTRAINT [PK_MoneyGramComunicationLogs] PRIMARY KEY CLUSTERED ([IdComunicationLogs] ASC)
);


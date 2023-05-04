CREATE TABLE [MoneyGram].[Agent] (
    [IdAgent]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [AgentName]         VARCHAR (200) NOT NULL,
    [Address]           VARCHAR (200) NULL,
    [City]              VARCHAR (200) NOT NULL,
    [State]             VARCHAR (200) NULL,
    [ReceiveCapability] BIT           NULL,
    [SendCapability]    BIT           NULL,
    [AgentPhone]        VARCHAR (200) NULL,
    [DateOfLastChange]  DATETIME      NULL,
    [CreationDate]      DATETIME      NOT NULL,
    [Active]            BIT           NOT NULL,
    CONSTRAINT [PK_MoneyGramAgent] PRIMARY KEY CLUSTERED ([IdAgent] ASC)
);


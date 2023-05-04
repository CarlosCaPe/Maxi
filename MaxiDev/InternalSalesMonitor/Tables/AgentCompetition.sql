CREATE TABLE [InternalSalesMonitor].[AgentCompetition] (
    [IdAgentCompetition] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]            INT            NOT NULL,
    [Transmitter]        NVARCHAR (MAX) NOT NULL,
    [Country]            NVARCHAR (MAX) NOT NULL,
    [FxRate]             NVARCHAR (MAX) NULL,
    [TransmitterFee]     NVARCHAR (MAX) NULL,
    [MaxiFee]            NVARCHAR (MAX) NULL,
    [EnterByIdUser]      INT            NOT NULL,
    [DateOfLastChange]   DATETIME       NOT NULL,
    CONSTRAINT [PK_AgentCompetition] PRIMARY KEY CLUSTERED ([IdAgentCompetition] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCompetition_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCompetition_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


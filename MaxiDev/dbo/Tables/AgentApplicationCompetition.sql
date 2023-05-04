CREATE TABLE [dbo].[AgentApplicationCompetition] (
    [IdAgentApplicationCompetition] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgentApplication]            INT            NOT NULL,
    [Transmitter]                   NVARCHAR (MAX) NOT NULL,
    [Country]                       NVARCHAR (MAX) NOT NULL,
    [FxRate]                        NVARCHAR (MAX) NOT NULL,
    [TransmitterFee]                NVARCHAR (MAX) NOT NULL,
    [MaxiFee]                       NVARCHAR (MAX) NOT NULL,
    [EnterByIdUser]                 INT            NOT NULL,
    [DateOfLastChange]              DATETIME       NOT NULL,
    CONSTRAINT [PK_AgentApplicationCompetition] PRIMARY KEY CLUSTERED ([IdAgentApplicationCompetition] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentApplicationCompetition_AgentApplication] FOREIGN KEY ([IdAgentApplication]) REFERENCES [dbo].[AgentApplications] ([IdAgentApplication]),
    CONSTRAINT [FK_AgentApplicationCompetition_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


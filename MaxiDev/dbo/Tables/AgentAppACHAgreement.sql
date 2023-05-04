CREATE TABLE [dbo].[AgentAppACHAgreement] (
    [IdAgentAppACHAgreement] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgentApplication]     INT            NOT NULL,
    [BankName]               NVARCHAR (MAX) NOT NULL,
    [Addreess]               NVARCHAR (MAX) NOT NULL,
    [City]                   NVARCHAR (MAX) NULL,
    [State]                  NVARCHAR (MAX) NULL,
    [ZipCode]                NVARCHAR (MAX) NULL,
    [EnterByIdUser]          INT            NOT NULL,
    [DateOfLastChange]       DATETIME       NOT NULL,
    CONSTRAINT [PK_AgentAppACHAgreement] PRIMARY KEY CLUSTERED ([IdAgentAppACHAgreement] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentAppACHAgreement_Application] FOREIGN KEY ([IdAgentApplication]) REFERENCES [dbo].[AgentApplications] ([IdAgentApplication]),
    CONSTRAINT [FK_AgentAppACHAgreement_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


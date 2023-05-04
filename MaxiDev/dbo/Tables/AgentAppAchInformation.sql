CREATE TABLE [dbo].[AgentAppAchInformation] (
    [IdAgentAppAchInformation] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgentApplication]       INT            NOT NULL,
    [BankName]                 NVARCHAR (MAX) NOT NULL,
    [NameOnAccount]            NVARCHAR (MAX) NOT NULL,
    [Address]                  NVARCHAR (MAX) NOT NULL,
    [AccountNumber]            NVARCHAR (MAX) NOT NULL,
    [RoutingNumber]            NVARCHAR (MAX) NOT NULL,
    [City]                     NVARCHAR (MAX) NOT NULL,
    [State]                    NVARCHAR (MAX) NOT NULL,
    [ZipCode]                  NVARCHAR (MAX) NOT NULL,
    [EnterByIdUser]            INT            NOT NULL,
    [DateOfLastChange]         DATETIME       NOT NULL,
    CONSTRAINT [PK_AgentAppAchInformation] PRIMARY KEY CLUSTERED ([IdAgentAppAchInformation] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentAchInformation_Application] FOREIGN KEY ([IdAgentApplication]) REFERENCES [dbo].[AgentApplications] ([IdAgentApplication]),
    CONSTRAINT [FK_AgentAchInformation_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


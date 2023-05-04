CREATE TABLE [Corp].[AgentSuspendedSubStatus] (
    [IdAgentSuspendedSubStatus] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]                   INT      NOT NULL,
    [IdMaxiDepartment]          INT      NOT NULL,
    [Suspended]                 BIT      DEFAULT ((0)) NOT NULL,
    [DateOfCreation]            DATETIME NOT NULL,
    [DateOfLastChange]          DATETIME NOT NULL,
    [EnterByIdUser]             INT      NOT NULL,
    CONSTRAINT [PK_IdAgentSuspendedSubStatus] PRIMARY KEY CLUSTERED ([IdAgentSuspendedSubStatus] ASC),
    CONSTRAINT [FK_SuspendedSubStatus_Department] FOREIGN KEY ([IdMaxiDepartment]) REFERENCES [Corp].[MaxiDepartment] ([IdMaxiDepartment])
);


CREATE TABLE [InternalSalesMonitor].[CallHistory] (
    [IdCallHistory]      INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]            INT            NOT NULL,
    [IdTaskStatus]       INT            NOT NULL,
    [IdTaskPriority]     INT            NOT NULL,
    [Note]               NVARCHAR (MAX) NOT NULL,
    [EnterByIdUser]      INT            NOT NULL,
    [CreationDate]       DATETIME       NOT NULL,
    [LastChangeByIdUser] INT            NULL,
    [DateOfLastChange]   DATETIME       NULL,
    CONSTRAINT [PK_CallHistoryAgent] PRIMARY KEY CLUSTERED ([IdCallHistory] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CallHistory_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_CallHistory_TaskPriority] FOREIGN KEY ([IdTaskPriority]) REFERENCES [InternalSalesMonitor].[TaskPriorities] ([IdTaskPriority]),
    CONSTRAINT [FK_CallHistory_TaskStatus] FOREIGN KEY ([IdTaskStatus]) REFERENCES [InternalSalesMonitor].[TaskStatuses] ([IdTaskStatus]),
    CONSTRAINT [FK_CallHistory_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


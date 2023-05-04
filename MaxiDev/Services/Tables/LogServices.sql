CREATE TABLE [Services].[LogServices] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [eventId]           INT           NULL,
    [logpriority]       INT           NULL,
    [severity]          VARCHAR (MAX) NULL,
    [title]             VARCHAR (MAX) NULL,
    [logdate]           DATETIME      NULL,
    [machineName]       VARCHAR (MAX) NULL,
    [appDomainName]     VARCHAR (MAX) NULL,
    [processId]         VARCHAR (MAX) NULL,
    [processName]       VARCHAR (MAX) NULL,
    [managedThreadName] VARCHAR (MAX) NULL,
    [win32ThreadId]     VARCHAR (MAX) NULL,
    [message]           VARCHAR (MAX) NULL,
    CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90)
);


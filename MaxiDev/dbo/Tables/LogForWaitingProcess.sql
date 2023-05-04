CREATE TABLE [dbo].[LogForWaitingProcess] (
    [idLogWaiting]     INT              IDENTITY (1, 1) NOT NULL,
    [idAgent]          INT              NOT NULL,
    [idUser]           INT              NOT NULL,
    [SessionId]        UNIQUEIDENTIFIER NULL,
    [Module]           VARCHAR (MAX)    NULL,
    [Action]           VARCHAR (MAX)    NULL,
    [Application]      VARCHAR (150)    NOT NULL,
    [isError]          BIT              NULL,
    [ErrorDescription] VARCHAR (MAX)    NULL,
    [StackTrace]       VARCHAR (MAX)    NULL,
    CONSTRAINT [PK_LogForWaitingProcess] PRIMARY KEY CLUSTERED ([idLogWaiting] ASC)
);


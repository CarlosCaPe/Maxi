CREATE TABLE [dbo].[LogMobileListener] (
    [IdLog]            INT            IDENTITY (1, 1) NOT NULL,
    [LogPriority]      INT            NOT NULL,
    [Severity]         INT            NOT NULL,
    [ExceptionMessage] VARCHAR (MAX)  NOT NULL,
    [LogDate]          DATETIME       NOT NULL,
    [ClientDatetime]   DATETIME       NULL,
    [DeviceId]         NVARCHAR (200) NOT NULL,
    [LogTag]           NVARCHAR (MAX) NOT NULL,
    [StackTrace]       NVARCHAR (MAX) NULL,
    [ErrorLocation]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ErrorLogMobileListener] PRIMARY KEY CLUSTERED ([IdLog] ASC) WITH (FILLFACTOR = 90)
);


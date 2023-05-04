CREATE TABLE [dbo].[MailQueueErrorLog] (
    [LogId]        INT           IDENTITY (1, 1) NOT NULL,
    [LogDate]      DATETIME      NULL,
    [ErrorMessage] VARCHAR (MAX) NULL,
    [Method]       VARCHAR (200) NULL,
    [FullRequest]  VARCHAR (MAX) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [PK_MailQueueErrorLog]
    ON [dbo].[MailQueueErrorLog]([LogId] ASC);


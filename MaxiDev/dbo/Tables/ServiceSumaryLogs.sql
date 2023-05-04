CREATE TABLE [dbo].[ServiceSumaryLogs] (
    [Id]               UNIQUEIDENTIFIER NOT NULL,
    [TickServiceLogId] UNIQUEIDENTIFIER NOT NULL,
    [DateLog]          DATETIME         NOT NULL,
    [Message]          VARCHAR (200)    NOT NULL,
    [Status]           INT              NOT NULL,
    CONSTRAINT [PK_ServiceSumaryLogs] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90)
);


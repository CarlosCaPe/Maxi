CREATE TABLE [dbo].[AuditLog] (
    [AuditLogId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [ObjectName]       VARCHAR (MAX) NULL,
    [Operation]        VARCHAR (50)  NULL,
    [Values]           XML           NULL,
    [DateOfLastChange] DATETIME      NULL,
    [EnterByIdUser]    INT           NULL,
    CONSTRAINT [PK_AuditLog] PRIMARY KEY CLUSTERED ([AuditLogId] ASC)
);


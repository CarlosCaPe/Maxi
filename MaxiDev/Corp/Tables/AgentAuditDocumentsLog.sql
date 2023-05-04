CREATE TABLE [Corp].[AgentAuditDocumentsLog] (
    [IdAgentAuditDocumentsLog] INT            IDENTITY (1, 1) NOT NULL,
    [IdUser]                   INT            NULL,
    [StateCode]                VARCHAR (MAX)  NULL,
    [Result]                   VARCHAR (1000) NULL,
    [Parameters]               VARCHAR (MAX)  NULL,
    [DateStart]                DATETIME       NULL,
    [DateEnd]                  DATETIME       NULL,
    [DateOfCreation]           DATETIME       NULL,
    CONSTRAINT [PK_AgentAuditDocumentslog] PRIMARY KEY CLUSTERED ([IdAgentAuditDocumentsLog] ASC),
    CONSTRAINT [FK_UserAgengAuditDocumentsLog] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


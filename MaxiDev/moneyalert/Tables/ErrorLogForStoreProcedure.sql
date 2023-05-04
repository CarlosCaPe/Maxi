CREATE TABLE [moneyalert].[ErrorLogForStoreProcedure] (
    [ErrorLogForStoreProcedureId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [StoreProcedure]              NVARCHAR (MAX) NULL,
    [Line]                        INT            NULL,
    [Message]                     NVARCHAR (MAX) NULL,
    [Number]                      INT            NULL,
    [Severity]                    INT            NULL,
    [State]                       INT            NULL,
    [ErrorDate]                   DATETIME       NULL,
    [XmlParameters]               NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_LogForStoreProcedure] PRIMARY KEY CLUSTERED ([ErrorLogForStoreProcedureId] ASC)
);


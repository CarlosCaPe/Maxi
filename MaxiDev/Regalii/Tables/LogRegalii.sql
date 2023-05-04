CREATE TABLE [Regalii].[LogRegalii] (
    [IdLogRegalii]   INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]        INT            NOT NULL,
    [IdUser]         INT            NOT NULL,
    [JsonRequest]    NVARCHAR (MAX) NULL,
    [JsonResponse]   NVARCHAR (MAX) NULL,
    [DateLastChange] DATETIME       NOT NULL,
    CONSTRAINT [PK_LogRegalii] PRIMARY KEY CLUSTERED ([IdLogRegalii] ASC),
    CONSTRAINT [FK_LogRegalii_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_LogRegalii_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


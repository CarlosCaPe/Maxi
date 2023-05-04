CREATE TABLE [dbo].[PendingFilesAgentApp] (
    [IdPendingfilesAgentApp] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgentApplication]     INT      NOT NULL,
    [IdDocumentType]         INT      NOT NULL,
    [ExpirationDate]         DATE     NULL,
    [IsUpload]               BIT      NOT NULL,
    [IdUserCreate]           INT      NOT NULL,
    [DateCreate]             DATETIME NULL,
    [IdUserLastChange]       INT      NOT NULL,
    [DateLastChange]         DATETIME NOT NULL,
    [IdGenericStatus]        INT      NOT NULL,
    [IdUploadFile]           INT      NULL,
    [SendNotification]       BIT      NULL,
    CONSTRAINT [PK_PendingFilesAgentApp] PRIMARY KEY CLUSTERED ([IdPendingfilesAgentApp] ASC),
    CONSTRAINT [FK_PendingFilesAgentApp_AgentApplications] FOREIGN KEY ([IdDocumentType]) REFERENCES [dbo].[DocumentTypes] ([IdDocumentType]),
    CONSTRAINT [FK_PendingFilesAgentApp_AgentApplications1] FOREIGN KEY ([IdAgentApplication]) REFERENCES [dbo].[AgentApplications] ([IdAgentApplication]),
    CONSTRAINT [FK_PendingFilesAgentApp_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_PendingFilesAgentApp_UploadFiles] FOREIGN KEY ([IdUploadFile]) REFERENCES [dbo].[UploadFiles] ([IdUploadFile])
);


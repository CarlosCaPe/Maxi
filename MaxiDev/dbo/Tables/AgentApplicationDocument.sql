CREATE TABLE [dbo].[AgentApplicationDocument] (
    [IdAgentApplicationDocument] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgentApplication]         INT            NOT NULL,
    [IdDocumentType]             INT            NOT NULL,
    [FileName]                   NVARCHAR (300) NOT NULL,
    [Extension]                  NVARCHAR (5)   NOT NULL,
    [Url]                        NVARCHAR (300) NOT NULL,
    [IsUpload]                   BIT            NOT NULL,
    [IdGenericStatus]            INT            NOT NULL,
    [CreationDate]               DATETIME       DEFAULT (getdate()) NOT NULL,
    [DateOfLastChange]           DATETIME       DEFAULT (getdate()) NOT NULL,
    [EnterByIdUser]              INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAgentApplicationDocument] ASC),
    FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    FOREIGN KEY ([IdAgentApplication]) REFERENCES [dbo].[AgentApplications] ([IdAgentApplication]),
    FOREIGN KEY ([IdDocumentType]) REFERENCES [dbo].[DocumentTypes] ([IdDocumentType]),
    FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);


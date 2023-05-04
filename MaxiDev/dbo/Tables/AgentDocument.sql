CREATE TABLE [dbo].[AgentDocument] (
    [IdAgentDocument]  INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]          INT            NOT NULL,
    [IdDocumentType]   INT            NOT NULL,
    [FileName]         NVARCHAR (300) NOT NULL,
    [Extension]        NVARCHAR (5)   NOT NULL,
    [Url]              NVARCHAR (300) NOT NULL,
    [IsUpload]         BIT            NOT NULL,
    [IdGenericStatus]  INT            NOT NULL,
    [CreationDate]     DATETIME       DEFAULT (getdate()) NOT NULL,
    [DateOfLastChange] DATETIME       DEFAULT (getdate()) NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAgentDocument] ASC),
    FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    FOREIGN KEY ([IdDocumentType]) REFERENCES [dbo].[DocumentTypes] ([IdDocumentType]),
    FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);


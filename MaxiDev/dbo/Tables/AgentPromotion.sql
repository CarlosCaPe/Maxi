CREATE TABLE [dbo].[AgentPromotion] (
    [IdAgentPromotion] INT            IDENTITY (1, 1) NOT NULL,
    [PromotionName]    NVARCHAR (MAX) NULL,
    [FileName]         NVARCHAR (MAX) NOT NULL,
    [FileGuid]         NVARCHAR (MAX) NOT NULL,
    [Extension]        NVARCHAR (MAX) NULL,
    [BeginDate]        DATETIME       NOT NULL,
    [EndDate]          DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [DateOfCreation]   DATETIME       NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [IdGenericStatus]  INT            NOT NULL,
    CONSTRAINT [PK_AgentCredential] PRIMARY KEY CLUSTERED ([IdAgentPromotion] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentPromotion_OPStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_AgentPromotion_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


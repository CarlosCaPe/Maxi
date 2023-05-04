CREATE TABLE [dbo].[CollectionNotificationRuleType] (
    [IdCollectionNotificationRuleType] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                             NVARCHAR (MAX) NOT NULL,
    [CreationDate]                     DATETIME       NOT NULL,
    [DateofLastChange]                 DATETIME       NOT NULL,
    [EnterByIdUser]                    INT            NOT NULL,
    [IdStatus]                         INT            NOT NULL,
    CONSTRAINT [PK_CollectionNotificationRuleType] PRIMARY KEY CLUSTERED ([IdCollectionNotificationRuleType] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CollectionNotificationRuleType_GenericStatus] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);


CREATE TABLE [dbo].[CollectionNotificationRule] (
    [IdCollectionNotificationRule]     INT            IDENTITY (1, 1) NOT NULL,
    [Name]                             NVARCHAR (MAX) NOT NULL,
    [IdAgent]                          INT            NULL,
    [IdAgentClass]                     INT            NULL,
    [IdOwner]                          INT            NULL,
    [IdCollectionNotificationRuleType] INT            NOT NULL,
    [Condition]                        INT            NULL,
    [JSONMessage]                      NVARCHAR (MAX) NULL,
    [TEXTMessage]                      NVARCHAR (MAX) NULL,
    [ShowNotification]                 BIT            NULL,
    [SendFax]                          BIT            NULL,
    [CreationDate]                     DATETIME       NOT NULL,
    [DateofLastChange]                 DATETIME       NOT NULL,
    [EnterByIdUser]                    INT            NOT NULL,
    [IdStatus]                         INT            NOT NULL,
    CONSTRAINT [FK_CollectionNotificationRule_CollectionNotificationRuleType] FOREIGN KEY ([IdCollectionNotificationRuleType]) REFERENCES [dbo].[CollectionNotificationRuleType] ([IdCollectionNotificationRuleType]),
    CONSTRAINT [FK_CollectionNotificationRule_GenericStatus] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_CollectionNotificationRule_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


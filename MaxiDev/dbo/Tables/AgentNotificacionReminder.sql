CREATE TABLE [dbo].[AgentNotificacionReminder] (
    [IdAgent]                          INT NOT NULL,
    [IdMessage]                        INT NOT NULL,
    [IdCollectionNotificationRuleType] INT NOT NULL,
    CONSTRAINT [FK_AgentNotificacionReminder_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentNotificacionReminder_CollectionNotificationRuleType] FOREIGN KEY ([IdCollectionNotificationRuleType]) REFERENCES [dbo].[CollectionNotificationRuleType] ([IdCollectionNotificationRuleType]),
    CONSTRAINT [FK_AgentNotificacionReminder_Messages] FOREIGN KEY ([IdMessage]) REFERENCES [msg].[Messages] ([IdMessage])
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161212-131604]
    ON [dbo].[AgentNotificacionReminder]([IdAgent] ASC, [IdMessage] ASC);


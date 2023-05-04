CREATE TABLE [dbo].[CollectionNotificationDeposit] (
    [IdAgent]     INT      NULL,
    [CollectDate] DATETIME NULL,
    [Percentage]  MONEY    NULL,
    CONSTRAINT [FK_Notifications_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);


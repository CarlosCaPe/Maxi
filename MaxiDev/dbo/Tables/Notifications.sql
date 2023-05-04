CREATE TABLE [dbo].[Notifications] (
    [IdNotification]     INT            IDENTITY (1, 1) NOT NULL,
    [IdAgentApplication] INT            NOT NULL,
    [IdSeller]           INT            NOT NULL,
    [IdNotificationType] INT            NOT NULL,
    [Title]              NVARCHAR (MAX) NULL,
    [ReadedByUser]       BIT            NOT NULL,
    [DateOfLastChange]   DATETIME       NOT NULL,
    [IdUserLastChange]   INT            NOT NULL,
    CONSTRAINT [PK_Notifications] PRIMARY KEY CLUSTERED ([IdNotification] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Notifications_AgentApplications] FOREIGN KEY ([IdAgentApplication]) REFERENCES [dbo].[AgentApplications] ([IdAgentApplication]),
    CONSTRAINT [FK_Notifications_Users] FOREIGN KEY ([IdSeller]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_Notifications_UsersLastChange] FOREIGN KEY ([IdUserLastChange]) REFERENCES [dbo].[Users] ([IdUser])
);


CREATE TABLE [dbo].[OptionUsersTemp] (
    [IdOption] INT           NOT NULL,
    [IdUser]   INT           NOT NULL,
    [Action]   VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_OptionUsersTemp] PRIMARY KEY CLUSTERED ([IdOption] ASC, [IdUser] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OptionUsersTemp_Option] FOREIGN KEY ([IdOption]) REFERENCES [dbo].[OptionTemp] ([IdOption]),
    CONSTRAINT [FK_OptionUsersTemp_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[UsersTemp] ([IdUser])
);


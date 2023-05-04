CREATE TABLE [dbo].[OptionUsers] (
    [IdOption] INT           NOT NULL,
    [IdUser]   INT           NOT NULL,
    [Action]   VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_OptionUsers] PRIMARY KEY CLUSTERED ([IdOption] ASC, [IdUser] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OptionUsers_Option] FOREIGN KEY ([IdOption]) REFERENCES [dbo].[Option] ([IdOption]),
    CONSTRAINT [FK_OptionUsers_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_OptionUsers_IdUser]
    ON [dbo].[OptionUsers]([IdUser] ASC);


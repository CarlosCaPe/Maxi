CREATE TABLE [dbo].[UsersAditionalInfo] (
    [IdUser]                   INT      NOT NULL,
    [DateOfChangeLastPassword] DATETIME NOT NULL,
    [AttemptsToLogin]          INT      CONSTRAINT [DF_UsersAditionalInfo_AttemptsToLogin] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [FK_UsersAditionalInfo_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_UsersAditionalInfo_IdUser]
    ON [dbo].[UsersAditionalInfo]([IdUser] ASC);


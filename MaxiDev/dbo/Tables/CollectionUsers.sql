CREATE TABLE [dbo].[CollectionUsers] (
    [IdUser]  INT NOT NULL,
    [IsAdmin] BIT DEFAULT ((0)) NOT NULL,
    [IsUser]  BIT NULL,
    CONSTRAINT [PK_CollectionUsers] PRIMARY KEY CLUSTERED ([IdUser] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CollectionUsers_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


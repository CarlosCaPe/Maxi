CREATE TABLE [dbo].[UsersSession] (
    [SessionGuid]        UNIQUEIDENTIFIER NOT NULL,
    [IdUser]             INT              NOT NULL,
    [IP]                 VARCHAR (50)     NOT NULL,
    [DateOfCreation]     DATETIME         NOT NULL,
    [LastAccess]         DATETIME         NOT NULL,
    [MachineDescription] NVARCHAR (MAX)   DEFAULT ('') NOT NULL,
    [FrameWorkVersion]   VARCHAR (50)     NULL,
    [OperativeSystem]    VARCHAR (100)    NULL,
    CONSTRAINT [PK_UsersSession] PRIMARY KEY CLUSTERED ([SessionGuid] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_UsersSession_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_UsersSession_IdUser]
    ON [dbo].[UsersSession]([IdUser] ASC)
    INCLUDE([DateOfCreation]);


GO
CREATE NONCLUSTERED INDEX [IDX_UsersSession_IdUser_SessionGuid]
    ON [dbo].[UsersSession]([IdUser] ASC, [SessionGuid] ASC);


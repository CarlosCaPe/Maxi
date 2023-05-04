CREATE TABLE [dbo].[UserPcAccess] (
    [IdUserPcAccess]    INT            IDENTITY (1, 1) NOT NULL,
    [PcIdentifier]      NVARCHAR (MAX) NOT NULL,
    [IdUser]            INT            NOT NULL,
    [DateOfFirstAccess] DATETIME       NOT NULL,
    [DateOfLastAccess]  DATETIME       NOT NULL,
    [IdPcIdentifier]    INT            NULL,
    CONSTRAINT [PK_UserPcAccess] PRIMARY KEY CLUSTERED ([IdUserPcAccess] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_UserPcAccess_Users1] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_UserPcAccess_IdUser]
    ON [dbo].[UserPcAccess]([IdUser] ASC);


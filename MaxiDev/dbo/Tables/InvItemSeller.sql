CREATE TABLE [dbo].[InvItemSeller] (
    [IdInvItemSeller]  INT      IDENTITY (1, 1) NOT NULL,
    [IdInvItem]        INT      NOT NULL,
    [IdUserSeller]     INT      NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    [EnterByIdUser]    INT      NOT NULL,
    CONSTRAINT [PK_InvItemSeller] PRIMARY KEY CLUSTERED ([IdInvItemSeller] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_InvItemSeller_InvItem] FOREIGN KEY ([IdInvItem]) REFERENCES [dbo].[InvItem] ([IdInvItem]),
    CONSTRAINT [FK_InvItemSeller_Users] FOREIGN KEY ([IdUserSeller]) REFERENCES [dbo].[Users] ([IdUser])
);


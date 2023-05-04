CREATE TABLE [dbo].[InvItem] (
    [IdInvItem]        INT            IDENTITY (1, 1) NOT NULL,
    [IdInvSubAccount]  INT            NOT NULL,
    [Description]      NVARCHAR (MAX) NOT NULL,
    [IdInvStatus]      INT            NOT NULL,
    [DateCreated]      INT            NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_InvItem] PRIMARY KEY CLUSTERED ([IdInvItem] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_InvItem_InvStatus] FOREIGN KEY ([IdInvStatus]) REFERENCES [dbo].[InvStatus] ([IdInvStatus]),
    CONSTRAINT [FK_InvItem_InvSubAccount] FOREIGN KEY ([IdInvSubAccount]) REFERENCES [dbo].[InvSubAccount] ([IdInvSubAccount])
);


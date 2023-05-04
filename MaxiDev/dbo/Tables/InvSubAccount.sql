CREATE TABLE [dbo].[InvSubAccount] (
    [IdInvSubAccount]  INT            IDENTITY (1, 1) NOT NULL,
    [IdInvAccount]     INT            NOT NULL,
    [SubAccountName]   NVARCHAR (MAX) NOT NULL,
    [CreatedOn]        DATETIME       NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_InvSubAccount] PRIMARY KEY CLUSTERED ([IdInvSubAccount] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_InvSubAccount_InvAccount] FOREIGN KEY ([IdInvAccount]) REFERENCES [dbo].[InvAccount] ([IdInvAccount])
);


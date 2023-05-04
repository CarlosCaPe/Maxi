CREATE TABLE [dbo].[InvAccount] (
    [IdInvAccount]     INT            IDENTITY (1, 1) NOT NULL,
    [AccountName]      NVARCHAR (MAX) NOT NULL,
    [CreatedOn]        DATETIME       NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_InvAccount] PRIMARY KEY CLUSTERED ([IdInvAccount] ASC) WITH (FILLFACTOR = 90)
);


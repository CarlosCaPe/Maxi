CREATE TABLE [dbo].[InvHistory] (
    [IdInvHistory]     INT            IDENTITY (1, 1) NOT NULL,
    [IdInvItem]        INT            NOT NULL,
    [DateofAsignation] DATETIME       NOT NULL,
    [AsignedTo]        NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_InvHistory] PRIMARY KEY CLUSTERED ([IdInvHistory] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_InvHistory_InvItem] FOREIGN KEY ([IdInvItem]) REFERENCES [dbo].[InvItem] ([IdInvItem])
);


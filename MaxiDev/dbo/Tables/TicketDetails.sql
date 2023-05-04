CREATE TABLE [dbo].[TicketDetails] (
    [IdTicketDetails]           INT            IDENTITY (1, 1) NOT NULL,
    [IdTicket]                  INT            NOT NULL,
    [NoteDate]                  DATETIME       NOT NULL,
    [Note]                      NVARCHAR (MAX) NULL,
    [IdUser]                    INT            NOT NULL,
    [LastChange_LastUserChange] NVARCHAR (MAX) NULL,
    [LastChange_LastDateChange] DATETIME       NOT NULL,
    [LastChange_LastIpChange]   NVARCHAR (MAX) NULL,
    [LastChange_LastNoteChange] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdTicketDetails] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [Ticket_Details] FOREIGN KEY ([IdTicket]) REFERENCES [dbo].[Tickets] ([IdTicket]),
    CONSTRAINT [TicketDetail_SelectedUser] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ix_TicketDetails_IdTicket]
    ON [dbo].[TicketDetails]([IdTicket] ASC);


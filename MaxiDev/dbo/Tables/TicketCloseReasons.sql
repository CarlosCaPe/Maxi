CREATE TABLE [dbo].[TicketCloseReasons] (
    [IdTicketCloseReason] INT            IDENTITY (1, 1) NOT NULL,
    [Description]         NVARCHAR (MAX) NULL,
    [descriptionES]       NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdTicketCloseReason] ASC) WITH (FILLFACTOR = 90)
);


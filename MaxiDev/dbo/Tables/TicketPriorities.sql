CREATE TABLE [dbo].[TicketPriorities] (
    [IdTicketPriority] INT            IDENTITY (1, 1) NOT NULL,
    [Description]      NVARCHAR (MAX) NULL,
    [Value]            INT            NOT NULL,
    [descriptionES]    NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdTicketPriority] ASC) WITH (FILLFACTOR = 90)
);


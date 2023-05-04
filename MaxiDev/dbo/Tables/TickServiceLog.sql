CREATE TABLE [dbo].[TickServiceLog] (
    [Id]       UNIQUEIDENTIFIER NOT NULL,
    [Code]     VARCHAR (20)     NOT NULL,
    [TickDate] DATETIME         NOT NULL,
    CONSTRAINT [PK_TickServiceLog_1] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TickServiceLog_Gateway] FOREIGN KEY ([Code]) REFERENCES [dbo].[Gateway] ([Code]) ON UPDATE CASCADE
);


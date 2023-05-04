CREATE TABLE [dbo].[ServiceSchedules] (
    [Code]      VARCHAR (20) NOT NULL,
    [DayOfWeek] INT          NOT NULL,
    [Time]      VARCHAR (5)  NOT NULL,
    CONSTRAINT [PK_ServiceSchedules_1] PRIMARY KEY CLUSTERED ([Code] ASC, [DayOfWeek] ASC, [Time] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ServiceSchedules_Gateway] FOREIGN KEY ([Code]) REFERENCES [dbo].[Gateway] ([Code]) ON UPDATE CASCADE
);


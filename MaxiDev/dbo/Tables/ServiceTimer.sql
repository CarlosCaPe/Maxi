CREATE TABLE [dbo].[ServiceTimer] (
    [Code]      VARCHAR (20) NOT NULL,
    [Interval]  DECIMAL (18) NOT NULL,
    [StartTime] VARCHAR (5)  NOT NULL,
    [EndTime]   VARCHAR (5)  NOT NULL,
    CONSTRAINT [PK_ServiceTimer] PRIMARY KEY CLUSTERED ([Code] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ServiceTimer_Gateway] FOREIGN KEY ([Code]) REFERENCES [dbo].[Gateway] ([Code]) ON UPDATE CASCADE
);


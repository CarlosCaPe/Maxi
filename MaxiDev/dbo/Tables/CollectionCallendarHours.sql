CREATE TABLE [dbo].[CollectionCallendarHours] (
    [IdAgent]   INT      NOT NULL,
    [DayNumber] INT      NOT NULL,
    [StartTime] TIME (0) NULL,
    [EndTime]   TIME (0) NULL,
    CONSTRAINT [PK_CollectionCallendarHours] PRIMARY KEY CLUSTERED ([IdAgent] ASC, [DayNumber] ASC),
    FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);


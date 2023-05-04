CREATE TABLE [Services].[ServiceSchedules] (
    [Code]      NVARCHAR (128) NOT NULL,
    [DayOfWeek] INT            NOT NULL,
    [Time]      NVARCHAR (10)  NOT NULL,
    CONSTRAINT [PK_ServiceSchedules] PRIMARY KEY CLUSTERED ([Code] ASC, [DayOfWeek] ASC, [Time] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [ServiceConfigurationSchedule_Schedule] FOREIGN KEY ([Code]) REFERENCES [Services].[ServiceConfigurationSchedule] ([Code])
);


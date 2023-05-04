CREATE TABLE [Services].[ServiceConfigurationTick] (
    [Code]      NVARCHAR (128) NOT NULL,
    [Interval]  INT            NOT NULL,
    [StartTime] VARCHAR (5)    NOT NULL,
    [EndTime]   VARCHAR (5)    NOT NULL,
    PRIMARY KEY CLUSTERED ([Code] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [ServiceConfigurationTicks_TypeConstraint_From_ServiceConfiguration_To_ServiceConfigurationTick] FOREIGN KEY ([Code]) REFERENCES [Services].[ServiceConfiguration] ([Code])
);


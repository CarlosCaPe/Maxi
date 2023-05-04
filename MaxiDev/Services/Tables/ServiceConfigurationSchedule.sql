CREATE TABLE [Services].[ServiceConfigurationSchedule] (
    [Code] NVARCHAR (128) NOT NULL,
    PRIMARY KEY CLUSTERED ([Code] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [ServiceConfigurationSchedule_TypeConstraint_From_ServiceConfiguration_To_ServiceConfigurationSchedule] FOREIGN KEY ([Code]) REFERENCES [Services].[ServiceConfiguration] ([Code])
);


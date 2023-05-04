CREATE TABLE [InternalSalesMonitor].[TaskPriorities] (
    [IdTaskPriority] INT           IDENTITY (1, 1) NOT NULL,
    [TaskPriority]   VARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdTaskPriority] ASC)
);


CREATE TABLE [InternalSalesMonitor].[TaskStatuses] (
    [IdTaskStatus] INT           IDENTITY (1, 1) NOT NULL,
    [TaskStatus]   VARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdTaskStatus] ASC)
);


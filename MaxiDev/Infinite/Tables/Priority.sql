CREATE TABLE [Infinite].[Priority] (
    [IdPriority]    INT            IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (100) NOT NULL,
    [PriorityLevel] INT            NOT NULL,
    [Description]   NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdPriority] ASC)
);


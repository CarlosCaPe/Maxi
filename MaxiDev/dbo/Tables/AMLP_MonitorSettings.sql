CREATE TABLE [dbo].[AMLP_MonitorSettings] (
    [IdMonitorSettings] INT           IDENTITY (1, 1) NOT NULL,
    [Name]              VARCHAR (100) NOT NULL,
    [Value]             INT           NULL,
    [MinValue]          INT           NULL,
    [MaxValue]          INT           NULL,
    [UnitOfMeasurement] VARCHAR (20)  NULL,
    [Notes]             VARCHAR (200) NULL,
    CONSTRAINT [PK_AMLPMonitorSettings] PRIMARY KEY CLUSTERED ([IdMonitorSettings] ASC)
);


CREATE TABLE [dbo].[AgentsReportWellsFargo] (
    [IdAgentsReportWellsFargo] INT      IDENTITY (1, 1) NOT NULL,
    [IdUserWhoGenerate]        INT      NOT NULL,
    [ReportDateGenerated]      DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_AgentsReportWellsFargo] PRIMARY KEY CLUSTERED ([IdAgentsReportWellsFargo] ASC)
);


CREATE TABLE [dbo].[AgentsReportWellsFargoDetail] (
    [IdAgentsReportWellsFargoDetail] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgentsReportWellsFargo]       INT      NOT NULL,
    [isAgent]                        BIT      DEFAULT ((0)) NULL,
    [idAgent]                        INT      NULL,
    [NeedsWFSubaccount]              BIT      NOT NULL,
    [NeedsWFSubaccountDate]          DATETIME NOT NULL,
    [NeedsWFSubaccountIdUser]        INT      NOT NULL,
    [RequestWFSubaccount]            BIT      NOT NULL,
    [RequestWFSubaccountDate]        DATETIME NOT NULL,
    [RequestWFSubaccountIdUser]      INT      NOT NULL,
    [WFSStatus]                      BIT      NOT NULL,
    [OpenDate]                       DATETIME NOT NULL,
    [IdUserSeller]                   INT      NOT NULL,
    [IdAgentStatus]                  INT      NOT NULL,
    CONSTRAINT [PK_AgentsReportWellsFargoDetail] PRIMARY KEY CLUSTERED ([IdAgentsReportWellsFargoDetail] ASC)
);


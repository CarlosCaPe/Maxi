CREATE TABLE [dbo].[AgentFolioPreFolio] (
    [IdAgent]  INT NOT NULL,
    [Folio]    INT DEFAULT ((0)) NOT NULL,
    [PreFolio] INT DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAgent] ASC) WITH (FILLFACTOR = 90)
);


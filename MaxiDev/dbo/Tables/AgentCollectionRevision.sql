CREATE TABLE [dbo].[AgentCollectionRevision] (
    [IdAgent]       INT   NOT NULL,
    [Revision]      BIT   DEFAULT ((0)) NOT NULL,
    [DepositAmount] MONEY DEFAULT ((0)) NULL,
    CONSTRAINT [PK_AgentCollectionRevision] PRIMARY KEY CLUSTERED ([IdAgent] ASC) WITH (FILLFACTOR = 90)
);


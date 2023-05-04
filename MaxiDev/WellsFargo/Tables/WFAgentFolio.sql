CREATE TABLE [WellsFargo].[WFAgentFolio] (
    [IdWFAgentFolio] INT IDENTITY (1, 1) NOT NULL,
    [IdAgent]        INT NOT NULL,
    [Folio]          INT NOT NULL,
    CONSTRAINT [PK_OtherProductsFolio] PRIMARY KEY CLUSTERED ([IdWFAgentFolio] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_WFAgentFolio_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent])
);


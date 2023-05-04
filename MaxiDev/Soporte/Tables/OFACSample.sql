CREATE TABLE [Soporte].[OFACSample] (
    [Id]             INT            NULL,
    [IdTransfer]     BIGINT         NULL,
    [Folio]          INT            NULL,
    [AgentCode]      VARCHAR (10)   NULL,
    [Entity]         VARCHAR (20)   NULL,
    [Name]           VARCHAR (200)  NULL,
    [FirstLastName]  VARCHAR (200)  NULL,
    [SecondLastName] VARCHAR (200)  NULL,
    [Percent]        FLOAT (53)     NULL,
    [Match]          XML            NULL,
    [FullMatch]      BIT            NULL,
    [Incremental]    INT            IDENTITY (1, 1) NOT NULL,
    [Qualification]  FLOAT (53)     NULL,
    [MatchDetail]    XML            NULL,
    [BestMatch]      VARCHAR (1000) NULL
);


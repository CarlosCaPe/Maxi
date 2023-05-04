CREATE TABLE [Elastic].[AgentLocationSearch_NewIX] (
    [idLocation]      INT            IDENTITY (1, 1) NOT NULL,
    [idAgent]         INT            NULL,
    [idAgentSchema]   INT            NULL,
    [idCountry]       INT            NULL,
    [idState]         INT            NULL,
    [idCity]          INT            NULL,
    [LocationName]    VARCHAR (2000) NULL,
    [idLocationIndex] VARCHAR (200)  NULL,
    [LastUpdate]      DATETIME       NULL,
    [idGenericStatus] INT            DEFAULT ((1)) NULL,
    [PaymentTypes]    VARCHAR (200)  NULL,
    CONSTRAINT [PK_AgentLocationSearch_NewIX] UNIQUE NONCLUSTERED ([idLocation] ASC)
);


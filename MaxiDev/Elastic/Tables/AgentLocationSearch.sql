CREATE TABLE [Elastic].[AgentLocationSearch] (
    [idLocation]      INT            IDENTITY (1, 1) NOT NULL,
    [idAgent]         INT            NULL,
    [idAgentSchema]   INT            NULL,
    [idCountry]       INT            NULL,
    [countryName]     VARCHAR (100)  NULL,
    [idState]         INT            NULL,
    [stateName]       VARCHAR (100)  NULL,
    [idCity]          INT            NULL,
    [cItyName]        VARCHAR (100)  NULL,
    [LocationName]    VARCHAR (2000) NULL,
    [CityStateName]   VARCHAR (1000) NULL,
    [idLocationIndex] VARCHAR (200)  NULL,
    [LastUpdate]      DATETIME       NULL,
    [idGenericStatus] INT            DEFAULT ((1)) NULL,
    [PaymentTypes]    VARCHAR (200)  NULL,
    [Synchronized]    BIT            CONSTRAINT [DF_Elastic_AgentLocationSearch_Synchronized] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AgentLocationSearch] UNIQUE NONCLUSTERED ([idLocation] ASC)
);


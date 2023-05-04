CREATE TABLE [dbo].[AMLP_Parameter] (
    [IdParameter] INT           IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (100) NOT NULL,
    [RiskValue]   INT           NOT NULL,
    CONSTRAINT [PK_AMLPParameter] PRIMARY KEY CLUSTERED ([IdParameter] ASC)
);


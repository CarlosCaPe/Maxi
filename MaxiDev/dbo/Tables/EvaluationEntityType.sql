CREATE TABLE [dbo].[EvaluationEntityType] (
    [IdEvaluationEntityType] INT           NOT NULL,
    [Name]                   VARCHAR (50)  NOT NULL,
    [Description]            VARCHAR (250) NOT NULL,
    CONSTRAINT [PK_EvaluationEntityType] PRIMARY KEY CLUSTERED ([IdEvaluationEntityType] ASC),
    CONSTRAINT [U_EvaluationEntityType_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);


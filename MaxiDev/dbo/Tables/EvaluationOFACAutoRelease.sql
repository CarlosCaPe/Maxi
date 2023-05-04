CREATE TABLE [dbo].[EvaluationOFACAutoRelease] (
    [IdEvaluationOFACAutoRelease] INT      IDENTITY (1, 1) NOT NULL,
    [IdReference]                 INT      NOT NULL,
    [IdEvaluationEntityType]      INT      NOT NULL,
    [EnableAutoRelease]           BIT      NOT NULL,
    [CreationDate]                DATETIME NULL,
    [DateOfLastChange]            DATETIME NULL,
    CONSTRAINT [PK_EvaluationOFACAutoRelease] PRIMARY KEY CLUSTERED ([IdEvaluationOFACAutoRelease] ASC),
    CONSTRAINT [FK_EvaluationOFACAutoRelease_EvaluationEntityType] FOREIGN KEY ([IdEvaluationEntityType]) REFERENCES [dbo].[EvaluationEntityType] ([IdEvaluationEntityType]),
    CONSTRAINT [UQ_EvaluationOFACAutoRelease] UNIQUE NONCLUSTERED ([IdReference] ASC, [IdEvaluationEntityType] ASC)
);


CREATE TABLE [dbo].[AMLP_ParameterConsiderationList] (
    [IdParameterConsiderationList] INT IDENTITY (1, 1) NOT NULL,
    [IdParameter]                  INT NOT NULL,
    [IdReference]                  INT NOT NULL,
    [RiskValue]                    INT NOT NULL,
    CONSTRAINT [PK_AMLPParameterConsiderationList] PRIMARY KEY CLUSTERED ([IdParameterConsiderationList] ASC),
    CONSTRAINT [FK_AMLPParameterConsiderationList_AMLPParameter] FOREIGN KEY ([IdParameter]) REFERENCES [dbo].[AMLP_Parameter] ([IdParameter]),
    CONSTRAINT [UQ_AMLPParameterConsiderationList] UNIQUE NONCLUSTERED ([IdParameter] ASC, [IdReference] ASC)
);


CREATE TABLE [dbo].[AMLP_ParameterDetail] (
    [IdParameterDetail] INT IDENTITY (1, 1) NOT NULL,
    [IdParameter]       INT NOT NULL,
    [MinValue]          INT NOT NULL,
    [MaxValue]          INT NOT NULL,
    [ResultValue]       INT NOT NULL,
    CONSTRAINT [PK_AMLPParameterDetail] PRIMARY KEY CLUSTERED ([IdParameterDetail] ASC),
    CONSTRAINT [FK_AMLPParameterDetail_AMLPParameter] FOREIGN KEY ([IdParameter]) REFERENCES [dbo].[AMLP_Parameter] ([IdParameter])
);


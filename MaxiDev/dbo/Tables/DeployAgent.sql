CREATE TABLE [dbo].[DeployAgent] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Version]     VARCHAR (12)  NULL,
    [Requeriment] VARCHAR (MAX) NULL,
    [DateVersion] DATETIME      NULL,
    CONSTRAINT [Pk_DeployAgent] PRIMARY KEY CLUSTERED ([Id] ASC)
);


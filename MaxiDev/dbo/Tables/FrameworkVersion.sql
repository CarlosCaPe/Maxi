CREATE TABLE [dbo].[FrameworkVersion] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [Release]    VARCHAR (50)  NULL,
    [Version]    VARCHAR (100) NULL,
    [CreatedBy]  INT           NULL,
    [CreateDate] DATE          NULL,
    CONSTRAINT [Pk_FrameworkVersion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


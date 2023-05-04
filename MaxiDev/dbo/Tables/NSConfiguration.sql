CREATE TABLE [dbo].[NSConfiguration] (
    [Name]        NVARCHAR (50)  NOT NULL,
    [Value]       NVARCHAR (200) NOT NULL,
    [Description] NVARCHAR (200) NULL,
    CONSTRAINT [PK_NetSuiteConfig] PRIMARY KEY CLUSTERED ([Name] ASC)
);


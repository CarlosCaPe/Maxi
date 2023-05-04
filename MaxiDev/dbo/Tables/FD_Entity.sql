CREATE TABLE [dbo].[FD_Entity] (
    [IdEntity] INT           NOT NULL,
    [Name]     NVARCHAR (80) NOT NULL,
    CONSTRAINT [PK_FDEntity] PRIMARY KEY CLUSTERED ([IdEntity] ASC),
    CONSTRAINT [UQ_FDEntity_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);


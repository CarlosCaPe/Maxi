CREATE TABLE [dbo].[NSProcessType] (
    [IdProcessType]       INT            NOT NULL,
    [Name]                NVARCHAR (200) NOT NULL,
    [IdProcessTypeParent] INT            NULL,
    CONSTRAINT [PK_NSProcess] PRIMARY KEY CLUSTERED ([IdProcessType] ASC),
    CONSTRAINT [FK_NSProcessType_IdProcessTypeParent] FOREIGN KEY ([IdProcessTypeParent]) REFERENCES [dbo].[NSProcessType] ([IdProcessType])
);


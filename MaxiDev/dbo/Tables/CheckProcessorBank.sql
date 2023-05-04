CREATE TABLE [dbo].[CheckProcessorBank] (
    [IdCheckProcessorBank] INT           NOT NULL,
    [Name]                 VARCHAR (100) NOT NULL,
    [ABACode]              VARCHAR (50)  NULL,
    CONSTRAINT [PK_CheckProcessorBank] PRIMARY KEY CLUSTERED ([IdCheckProcessorBank] ASC)
);


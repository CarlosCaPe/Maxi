CREATE TABLE [dbo].[CheckBundle] (
    [IdCheckBundle]           INT           IDENTITY (1, 1) NOT NULL,
    [FileIdentifier]          VARCHAR (50)  NOT NULL,
    [BundleSequence]          INT           NOT NULL,
    [Amount]                  MONEY         NULL,
    [ItemsWithinBundleCount]  INT           NULL,
    [ImagesWithinBundleCount] INT           NULL,
    [CreateDate]              DATETIME      NOT NULL,
    [ApplyDate]               DATETIME      NULL,
    [FileName]                VARCHAR (255) NULL,
    CONSTRAINT [PK_CheckBundle] PRIMARY KEY CLUSTERED ([IdCheckBundle] ASC)
);


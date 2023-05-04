CREATE TABLE [dbo].[DocumentOwnerType] (
    [IdDocumentOwnerType] INT           NOT NULL,
    [Name]                VARCHAR (200) NOT NULL,
    [DateOfLastChange]    DATETIME      NOT NULL,
    [EnterByIdUser]       INT           NOT NULL,
    CONSTRAINT [PK_DocumentOwnerType] PRIMARY KEY CLUSTERED ([IdDocumentOwnerType] ASC)
);


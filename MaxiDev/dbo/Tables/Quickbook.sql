CREATE TABLE [dbo].[Quickbook] (
    [IdQuickbook]      INT            NOT NULL,
    [QuickbookName]    NVARCHAR (100) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_Quickbook] PRIMARY KEY CLUSTERED ([IdQuickbook] ASC) WITH (FILLFACTOR = 90)
);


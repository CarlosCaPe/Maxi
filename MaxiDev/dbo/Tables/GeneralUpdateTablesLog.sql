CREATE TABLE [dbo].[GeneralUpdateTablesLog] (
    [IdLog]          INT            IDENTITY (1, 1) NOT NULL,
    [TableName]      NVARCHAR (MAX) NOT NULL,
    [RowName]        NVARCHAR (150) NOT NULL,
    [OldValue]       NVARCHAR (MAX) NOT NULL,
    [NewValue]       NVARCHAR (MAX) NOT NULL,
    [IdUser]         INT            NOT NULL,
    [IdRow]          INT            NOT NULL,
    [IdTextRow]      NVARCHAR (255) NOT NULL,
    [DateOfCreation] DATETIME       NOT NULL,
    [Description]    NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_IdLog] PRIMARY KEY CLUSTERED ([IdLog] ASC)
);


CREATE TABLE [msg].[MessageStatus] (
    [IdMessageStatus] INT            IDENTITY (1, 1) NOT NULL,
    [Name]            NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_MessageStatus] PRIMARY KEY CLUSTERED ([IdMessageStatus] ASC) WITH (FILLFACTOR = 90)
);


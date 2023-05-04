CREATE TABLE [dbo].[OtherProducts] (
    [IdOtherProducts] INT            NOT NULL,
    [Description]     NVARCHAR (MAX) NOT NULL,
    [Visible]         BIT            NOT NULL,
    CONSTRAINT [PK_Provider] PRIMARY KEY CLUSTERED ([IdOtherProducts] ASC) WITH (FILLFACTOR = 90)
);


CREATE TABLE [Teleprompter].[FormatTags] (
    [IdTag]           INT           IDENTITY (1, 1) NOT NULL,
    [Tag]             VARCHAR (100) NULL,
    [IdGenericStatus] INT           NULL,
    [EnterByIdUser]   INT           NOT NULL,
    [CreationDate]    DATETIME      NOT NULL,
    CONSTRAINT [FK_FormatTags_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


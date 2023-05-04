CREATE TABLE [dbo].[News] (
    [IdNews]          INT            IDENTITY (1, 1) NOT NULL,
    [DateInsert]      DATETIME       NOT NULL,
    [BeginDate]       DATETIME       NOT NULL,
    [EndDate]         DATETIME       NOT NULL,
    [Title]           NVARCHAR (50)  NOT NULL,
    [News]            NVARCHAR (MAX) NOT NULL,
    [EnterByIdUser]   INT            NOT NULL,
    [IdGenericStatus] INT            NOT NULL,
    [NewsSpanish]     NVARCHAR (MAX) DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_News] PRIMARY KEY CLUSTERED ([IdNews] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_News_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_News_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


CREATE TABLE [dbo].[CheckOFACReview] (
    [IdCheckOFACReview] INT            IDENTITY (1, 1) NOT NULL,
    [IdCheck]           INT            NULL,
    [IdUserReview]      INT            NULL,
    [DateOfReview]      DATETIME       NULL,
    [IdOFACAction]      INT            NULL,
    [Note]              NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CheckOFACReview] PRIMARY KEY CLUSTERED ([IdCheckOFACReview] ASC),
    CONSTRAINT [FK_CheckOFACReview_Users1] FOREIGN KEY ([IdUserReview]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_CheckOFACReview_IdCheck_IdUserReview]
    ON [dbo].[CheckOFACReview]([IdCheck] ASC, [IdUserReview] ASC);


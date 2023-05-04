CREATE TABLE [dbo].[StateNote] (
    [IdStateNote]                INT            IDENTITY (1, 1) NOT NULL,
    [IdState]                    INT            NOT NULL,
    [ComplaintNoticeEnglish]     NVARCHAR (MAX) NULL,
    [ComplaintNoticeSpanish]     NVARCHAR (MAX) NULL,
    [AffiliationNoticeEnglish]   NVARCHAR (MAX) NULL,
    [AffiliationNoticeSpanish]   NVARCHAR (MAX) NULL,
    [ComplaintNoticePortugues]   VARCHAR (MAX)  DEFAULT (NULL) NULL,
    [AffiliationNoticePortugues] VARCHAR (MAX)  DEFAULT (NULL) NULL,
    CONSTRAINT [PK_StateNote] PRIMARY KEY CLUSTERED ([IdStateNote] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_StateNote_State] FOREIGN KEY ([IdState]) REFERENCES [dbo].[State] ([IdState])
);


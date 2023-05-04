CREATE TABLE [dbo].[ContactEmail] (
    [IdContactEmail]   INT           IDENTITY (1, 1) NOT NULL,
    [IdContactEntity]  INT           NOT NULL,
    [IdReference]      INT           NOT NULL,
    [Email]            VARCHAR (200) NULL,
    [IsPrincipal]      BIT           NULL,
    [EnterByIdUser]    INT           NOT NULL,
    [CreateDate]       DATETIME      NOT NULL,
    [ChangeByUser]     INT           NULL,
    [DateOfLastChange] DATETIME      NULL,
    [Active]           BIT           CONSTRAINT [DF_ContactEmail_Active] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_ContactEmail] PRIMARY KEY CLUSTERED ([IdContactEmail] ASC),
    CONSTRAINT [FK_ContactEmail_ChangeByUser] FOREIGN KEY ([ChangeByUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_ContactEmail_EnterByIdUser] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_ContactEmail_IdContactEntity] FOREIGN KEY ([IdContactEntity]) REFERENCES [dbo].[ContactEntity] ([IdContactEntity])
);


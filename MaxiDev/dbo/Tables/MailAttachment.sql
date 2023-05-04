CREATE TABLE [dbo].[MailAttachment] (
    [idAttachment] INT           IDENTITY (1, 1) NOT NULL,
    [IdMailQueue]  BIGINT        NOT NULL,
    [TemplateId]   INT           NOT NULL,
    [FileName]     VARCHAR (255) NOT NULL,
    [Content]      VARCHAR (MAX) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Pk_MailAttachment]
    ON [dbo].[MailAttachment]([idAttachment] ASC);


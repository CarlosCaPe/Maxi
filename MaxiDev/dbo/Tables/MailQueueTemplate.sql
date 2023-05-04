CREATE TABLE [dbo].[MailQueueTemplate] (
    [TemplateId] INT  IDENTITY (1, 1) NOT NULL,
    [Content]    TEXT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Pk_MailQueueTemplate]
    ON [dbo].[MailQueueTemplate]([TemplateId] ASC);


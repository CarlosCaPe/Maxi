CREATE TABLE [dbo].[MailQueue] (
    [IdMailQueue]  BIGINT        IDENTITY (1, 1) NOT NULL,
    [Source]       VARCHAR (255) NULL,
    [ReplyTo]      VARCHAR (255) NOT NULL,
    [MsgRecipient] VARCHAR (255) NOT NULL,
    [MsgCC]        VARCHAR (255) NULL,
    [MsgCCO]       VARCHAR (255) NULL,
    [Subject]      VARCHAR (255) NULL,
    [Body]         VARCHAR (MAX) NULL,
    [TemplateId]   INT           NULL,
    [CreateDate]   DATETIME      NOT NULL,
    [SendDate]     DATETIME      NOT NULL,
    [MailSent]     DATETIME      NULL,
    [Resend]       BIT           DEFAULT ((0)) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Pk_MailQueue]
    ON [dbo].[MailQueue]([IdMailQueue] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix3_MailQueue]
    ON [dbo].[MailQueue]([TemplateId] ASC, [SendDate] ASC)
    INCLUDE([IdMailQueue], [MailSent], [Resend]);


GO
CREATE NONCLUSTERED INDEX [IX_MailQueue_Source]
    ON [dbo].[MailQueue]([Source] ASC)
    INCLUDE([MsgRecipient], [Subject]);


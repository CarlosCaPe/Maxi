CREATE TABLE [moneyalert].[ChatDetail] (
    [IdChatDetail]        INT            IDENTITY (1, 1) NOT NULL,
    [IdChat]              INT            NOT NULL,
    [IdPersonRole]        INT            NOT NULL,
    [ChatMessage]         NVARCHAR (MAX) NOT NULL,
    [EnteredDate]         DATETIME       NOT NULL,
    [ChatMessageStatusId] INT            NULL,
    CONSTRAINT [PK_ChatDetail] PRIMARY KEY CLUSTERED ([IdChatDetail] ASC),
    CONSTRAINT [FK_ChatDetail_Chat] FOREIGN KEY ([IdChat]) REFERENCES [moneyalert].[Chat] ([IdChat]),
    CONSTRAINT [FK_ChatDetail_ChatMessageStatus] FOREIGN KEY ([ChatMessageStatusId]) REFERENCES [moneyalert].[ChatMessageStatus] ([ChatMessageStatusId])
);


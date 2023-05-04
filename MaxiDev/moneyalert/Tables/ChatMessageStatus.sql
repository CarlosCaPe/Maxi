CREATE TABLE [moneyalert].[ChatMessageStatus] (
    [ChatMessageStatusId] INT            IDENTITY (1, 1) NOT NULL,
    [ChatMessageStatus]   NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_ChatMessageStatus] PRIMARY KEY CLUSTERED ([ChatMessageStatusId] ASC)
);


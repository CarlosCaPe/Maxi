CREATE TABLE [moneyalert].[StatusChangePushMessageDetail] (
    [IdStatusChangePushMessageDetail] BIGINT         IDENTITY (1, 1) NOT NULL,
    [IdStatusChangePushMessage]       BIGINT         NULL,
    [DateOfDetail]                    DATETIME       DEFAULT (getdate()) NOT NULL,
    [HasError]                        BIT            DEFAULT ((0)) NOT NULL,
    [MessageError]                    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_StatusChangePushMessageDetail] PRIMARY KEY CLUSTERED ([IdStatusChangePushMessageDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FKDetail_StatusChangePushMessage] FOREIGN KEY ([IdStatusChangePushMessage]) REFERENCES [moneyalert].[StatusChangePushMessage] ([IdStatusChangePushMessage])
);


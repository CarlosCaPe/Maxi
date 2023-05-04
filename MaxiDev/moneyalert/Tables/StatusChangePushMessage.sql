CREATE TABLE [moneyalert].[StatusChangePushMessage] (
    [IdStatusChangePushMessage] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Claimcode]                 NVARCHAR (MAX) NOT NULL,
    [CreationDate]              DATETIME       DEFAULT (getdate()) NOT NULL,
    [SendDate]                  DATETIME       NULL,
    [IsSend]                    BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_StatusChangePushMessage] PRIMARY KEY CLUSTERED ([IdStatusChangePushMessage] ASC) WITH (FILLFACTOR = 90)
);


CREATE TABLE [dbo].[LogForUnclaimedHoldsBatch] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [IdUser]      INT            NULL,
    [IdStatus]    INT            NULL,
    [ClaimCode]   NVARCHAR (50)  NULL,
    [Description] NVARCHAR (MAX) NULL,
    [LogDate]     DATETIME       NULL,
    CONSTRAINT [PK_LogForUnclaimedHoldsBatch] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90)
);


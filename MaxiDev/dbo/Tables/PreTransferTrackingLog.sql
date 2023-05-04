CREATE TABLE [dbo].[PreTransferTrackingLog] (
    [IdTracking]    INT           IDENTITY (1, 1) NOT NULL,
    [ServerDate]    DATETIME      NULL,
    [idPreTransfer] INT           NULL,
    [Reason]        VARCHAR (MAX) NULL
);


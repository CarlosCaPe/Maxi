CREATE TABLE [dbo].[TransfersUpdateInProgress] (
    [IdTransfer]       INT      NOT NULL,
    [IdUser]           INT      NOT NULL,
    [DateOfModified]   DATETIME NOT NULL,
    [OriginalIdStatus] INT      NULL
);


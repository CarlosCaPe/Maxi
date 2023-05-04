CREATE TABLE [dbo].[ClaimCodeNotificationRules] (
    [IdClaimCodeNotificationRules] INT IDENTITY (1, 1) NOT NULL,
    [IdPayer]                      INT NULL,
    [MinimunFolio]                 INT NULL,
    [RangeFolio]                   INT NULL,
    [NextFolioToNotification]      INT NULL
);


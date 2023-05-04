CREATE TABLE [moneyalert].[Likes] (
    [IdLikes]          INT      IDENTITY (1, 1) NOT NULL,
    [LikeStatus]       INT      NOT NULL,
    [IdTransfer]       INT      NOT NULL,
    [IdPersonRole]     INT      NOT NULL,
    [EnteredDate]      DATETIME NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    CONSTRAINT [PK_Likes] PRIMARY KEY CLUSTERED ([IdLikes] ASC)
);


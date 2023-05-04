CREATE TABLE [dbo].[SellerSessionLog] (
    [IdSellerSessionLog] INT            IDENTITY (1, 1) NOT NULL,
    [IdUserSeller]       INT            NOT NULL,
    [DeviceId]           NVARCHAR (100) NULL,
    [DateOfCreation]     DATETIME       NOT NULL,
    CONSTRAINT [PK_SellerSessionLog] PRIMARY KEY CLUSTERED ([IdSellerSessionLog] ASC)
);


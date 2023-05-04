CREATE TABLE [Regalii].[Notes] (
    [IdNote]         INT            IDENTITY (1, 1) NOT NULL,
    [IdTransferR]    BIGINT         NULL,
    [IdUser]         INT            NULL,
    [Note]           NVARCHAR (MAX) NOT NULL,
    [DateOfCreation] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdNote] ASC),
    FOREIGN KEY ([IdTransferR]) REFERENCES [Regalii].[TransferR] ([IdTransferR]),
    FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


CREATE TABLE [Infinite].[MessageTypes] (
    [IdMessageType] INT            IDENTITY (1, 1) NOT NULL,
    [MessageType]   NVARCHAR (100) NULL,
    [Description]   NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdMessageType] ASC)
);


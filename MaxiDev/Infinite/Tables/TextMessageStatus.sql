CREATE TABLE [Infinite].[TextMessageStatus] (
    [IdTextMessageStatus] INT            IDENTITY (1, 1) NOT NULL,
    [StatusName]          NVARCHAR (MAX) NOT NULL,
    [Description]         NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdTextMessageStatus] ASC)
);


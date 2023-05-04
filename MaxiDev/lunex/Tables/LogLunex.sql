CREATE TABLE [lunex].[LogLunex] (
    [IdLogLunex]     INT            IDENTITY (1, 1) NOT NULL,
    [IdUser]         INT            NOT NULL,
    [Request]        NVARCHAR (MAX) NULL,
    [Response]       NVARCHAR (MAX) NULL,
    [DateLastChange] DATETIME       NOT NULL,
    CONSTRAINT [PK_LogTransferTo] PRIMARY KEY CLUSTERED ([IdLogLunex] ASC),
    CONSTRAINT [FK_LogLunex_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


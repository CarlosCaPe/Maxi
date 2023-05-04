CREATE TABLE [TransFerTo].[LogTransferTo] (
    [IdLogTransferTo]    INT            IDENTITY (1, 1) NOT NULL,
    [IdUser]             INT            NOT NULL,
    [Request]            NVARCHAR (MAX) NULL,
    [Response]           NVARCHAR (MAX) NULL,
    [DateLastChange]     DATETIME       NOT NULL,
    [Authenticationkey]  BIGINT         NOT NULL,
    [IdRequestType]      INT            NOT NULL,
    [Destination_Number] NVARCHAR (500) NULL,
    [ReturnCode]         INT            NULL,
    CONSTRAINT [PK_LogTransferTo] PRIMARY KEY CLUSTERED ([IdLogTransferTo] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_LogTransferTo_RequestType] FOREIGN KEY ([IdRequestType]) REFERENCES [TransFerTo].[RequestType] ([IdRequestType]),
    CONSTRAINT [FK_LogTransferTo_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


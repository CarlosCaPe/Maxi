CREATE TABLE [dbo].[LogForListenerWinService] (
    [IdLog]          INT            IDENTITY (1, 1) NOT NULL,
    [Type]           VARCHAR (50)   NOT NULL,
    [Proyect]        VARCHAR (100)  NOT NULL,
    [ClientDatetime] DATETIME       NOT NULL,
    [ServerDatetime] DATETIME       NOT NULL,
    [Message]        NVARCHAR (MAX) NOT NULL,
    [StackTrace]     NVARCHAR (MAX) NULL,
    [Priority]       INT            NULL,
    CONSTRAINT [PK_LogForListenerWinService] PRIMARY KEY CLUSTERED ([IdLog] ASC) WITH (FILLFACTOR = 90)
);


CREATE TABLE [dbo].[ErrorLogForStoreProcedure] (
    [IdErrorLogForStoreProcedure] INT            IDENTITY (1, 1) NOT NULL,
    [StoreProcedure]              NVARCHAR (MAX) NULL,
    [ErrorDate]                   DATETIME       NULL,
    [ErrorMessage]                NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ErrorLogForStoreProcedure] PRIMARY KEY CLUSTERED ([IdErrorLogForStoreProcedure] ASC) WITH (FILLFACTOR = 90)
);


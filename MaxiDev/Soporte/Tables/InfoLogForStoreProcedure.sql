CREATE TABLE [Soporte].[InfoLogForStoreProcedure] (
    [IdInfoLogForStoreProcedure] INT            IDENTITY (1, 1) NOT NULL,
    [StoreProcedure]             NVARCHAR (MAX) NULL,
    [InfoDate]                   DATETIME       NULL,
    [InfoMessage]                NVARCHAR (MAX) NULL,
    [ExtraData]                  NVARCHAR (MAX) NULL,
    [XML]                        XML            NULL,
    CONSTRAINT [PK_InfoLogForStoreProcedure] PRIMARY KEY CLUSTERED ([IdInfoLogForStoreProcedure] ASC) WITH (FILLFACTOR = 90)
);


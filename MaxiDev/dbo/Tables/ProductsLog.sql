CREATE TABLE [dbo].[ProductsLog] (
    [id]        INT           IDENTITY (1, 1) NOT NULL,
    [idProduct] INT           NOT NULL,
    [logDate]   DATETIME      NOT NULL,
    [idAgent]   INT           NULL,
    [Provider]  VARCHAR (30)  NULL,
    [Operation] VARCHAR (MAX) NULL,
    [Message]   VARCHAR (MAX) NULL,
    [Request]   VARCHAR (MAX) NULL,
    [Response]  VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 90)
);


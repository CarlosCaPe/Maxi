CREATE TABLE [dbo].[UnitellerRequestLog] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [fecha]       DATETIME      NULL,
    [claimcode]   VARCHAR (30)  NULL,
    [RequestType] VARCHAR (30)  NULL,
    [Request]     VARCHAR (MAX) NULL,
    CONSTRAINT [PK_UnitellerRequestLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90)
);


CREATE TABLE [TransFerTo].[RequestType] (
    [IdRequestType] INT            IDENTITY (1, 1) NOT NULL,
    [ResquestName]  NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_RequestType] PRIMARY KEY CLUSTERED ([IdRequestType] ASC) WITH (FILLFACTOR = 90)
);


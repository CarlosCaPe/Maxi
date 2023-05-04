CREATE TABLE [dbo].[ServiceGeneralLog] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Code]     VARCHAR (20)  NOT NULL,
    [LogDate]  DATETIME      NOT NULL,
    [Category] VARCHAR (20)  NOT NULL,
    [Message]  VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_ServiceGeneralLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ServiceGeneralLog_Gateway] FOREIGN KEY ([Code]) REFERENCES [dbo].[Gateway] ([Code]) ON UPDATE CASCADE
);


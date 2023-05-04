CREATE TABLE [dbo].[ServiceAttributes] (
    [Code]         VARCHAR (20)  NOT NULL,
    [AttributeKey] VARCHAR (30)  NOT NULL,
    [Value]        VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_ServiceAttributes] PRIMARY KEY CLUSTERED ([Code] ASC, [AttributeKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ServiceAttributes_Gateway] FOREIGN KEY ([Code]) REFERENCES [dbo].[Gateway] ([Code]) ON UPDATE CASCADE
);


CREATE TABLE [dbo].[ServiceAttributesTemp] (
    [Code]         VARCHAR (20)  NOT NULL,
    [AttributeKey] VARCHAR (30)  NOT NULL,
    [Value]        VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_ServiceAttributesTemp] PRIMARY KEY CLUSTERED ([Code] ASC, [AttributeKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ServiceAttributesTemp_Gateway] FOREIGN KEY ([Code]) REFERENCES [dbo].[Gateway] ([Code]) ON UPDATE CASCADE
);


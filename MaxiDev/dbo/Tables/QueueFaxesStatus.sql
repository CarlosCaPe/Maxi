CREATE TABLE [dbo].[QueueFaxesStatus] (
    [IdQueueFaxStatus] INT          NOT NULL,
    [Name]             VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_QueueFaxesStatus] PRIMARY KEY CLUSTERED ([IdQueueFaxStatus] ASC) WITH (FILLFACTOR = 90)
);


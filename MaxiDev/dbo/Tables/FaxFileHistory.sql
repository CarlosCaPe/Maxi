CREATE TABLE [dbo].[FaxFileHistory] (
    [IdFaxFileHistory] INT            IDENTITY (1, 1) NOT NULL,
    [IdQueueFax]       INT            NOT NULL,
    [IdFaxType]        INT            NOT NULL,
    [FileName]         NVARCHAR (MAX) NOT NULL,
    [DateOfCreation]   DATETIME       NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [IsDeleted]        BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_FaxFileHistory] PRIMARY KEY CLUSTERED ([IdFaxFileHistory] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_FaxFileHistory_FaxType] FOREIGN KEY ([IdFaxType]) REFERENCES [dbo].[FaxType] ([IdFaxType]),
    CONSTRAINT [FK_FaxFileHistory_QueueFaxes] FOREIGN KEY ([IdQueueFax]) REFERENCES [dbo].[QueueFaxes] ([IdQueueFax])
);


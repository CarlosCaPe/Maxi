CREATE TABLE [dbo].[QueueFaxes] (
    [IdQueueFax]       INT          IDENTITY (1, 1) NOT NULL,
    [IdAgent]          INT          NOT NULL,
    [Parameters]       XML          NOT NULL,
    [ReportName]       VARCHAR (50) NOT NULL,
    [Priority]         INT          NOT NULL,
    [IdQueueFaxStatus] INT          NOT NULL,
    [DateInsert]       DATETIME     CONSTRAINT [DF_QueueFaxes_DateInsert] DEFAULT (getdate()) NOT NULL,
    [DateBeginProcess] DATETIME     NULL,
    [DateEndProcess]   DATETIME     NULL,
    [EnterByIdUser]    INT          NOT NULL,
    CONSTRAINT [PK_QueueFaxes] PRIMARY KEY CLUSTERED ([IdQueueFax] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_QueueFaxes_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_QueueFaxes_QueueFaxesStatus] FOREIGN KEY ([IdQueueFaxStatus]) REFERENCES [dbo].[QueueFaxesStatus] ([IdQueueFaxStatus]),
    CONSTRAINT [FK_QueueFaxes_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ix_QueueFaxesIdQueueFaxStatusIncludeIdQueueFaxPriority]
    ON [dbo].[QueueFaxes]([IdQueueFaxStatus] ASC)
    INCLUDE([IdQueueFax], [Priority]);


GO
CREATE NONCLUSTERED INDEX [ix_QueueFaxes_IdAgent_ReportName_DateInsert]
    ON [dbo].[QueueFaxes]([IdAgent] ASC, [ReportName] ASC, [DateInsert] ASC);


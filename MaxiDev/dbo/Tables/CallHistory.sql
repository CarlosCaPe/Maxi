CREATE TABLE [dbo].[CallHistory] (
    [IdCallHistory]    INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]          INT            NOT NULL,
    [IdUser]           INT            NOT NULL,
    [IdCallStatus]     INT            NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [Note]             NVARCHAR (MAX) NULL,
    [IsDirectMessage]  BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CallHistory] PRIMARY KEY CLUSTERED ([IdCallHistory] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CallHistory_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_CallHistory_CallStatus] FOREIGN KEY ([IdCallStatus]) REFERENCES [dbo].[CallStatus] ([IdCallStatus]),
    CONSTRAINT [FK_CallHistory_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX1_callhistory]
    ON [dbo].[CallHistory]([IdAgent] ASC, [DateOfLastChange] ASC)
    INCLUDE([IdUser], [IdCallStatus]);


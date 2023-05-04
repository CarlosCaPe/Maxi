CREATE TABLE [dbo].[LogForJobProcess] (
    [IdLogForJobProcess] BIGINT         IDENTITY (1, 1) NOT NULL,
    [JobName]            NVARCHAR (MAX) NOT NULL,
    [ReferenceId]        BIGINT         NULL,
    [Message]            NVARCHAR (MAX) NOT NULL,
    [HasError]           BIT            DEFAULT ((0)) NOT NULL,
    [InsertedDate]       DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdLogForJobProcess] ASC)
);


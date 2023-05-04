CREATE TABLE [dbo].[NSProcessJob] (
    [IdProcessJob]  INT            IDENTITY (1, 1) NOT NULL,
    [IdProcessType] INT            NOT NULL,
    [IdJob]         NVARCHAR (200) NOT NULL,
    [CreationDate]  DATETIME       NULL,
    [Status]        NVARCHAR (50)  NULL,
    [Response]      XML            NULL,
    [LastUpdate]    DATETIME       NULL,
    CONSTRAINT [PK_NSProcessJobs] PRIMARY KEY CLUSTERED ([IdProcessJob] ASC),
    CONSTRAINT [FK_NSProcessJobs_NSProcessJobs] FOREIGN KEY ([IdProcessType]) REFERENCES [dbo].[NSProcessType] ([IdProcessType]),
    CONSTRAINT [UQ_NSProcessJobs] UNIQUE NONCLUSTERED ([IdJob] ASC)
);


CREATE TABLE [dbo].[ABABlocked] (
    [IdABABlocked] INT           IDENTITY (1, 1) NOT NULL,
    [ABA]          NVARCHAR (20) NULL,
    [CreateDate]   DATETIME      NOT NULL,
    [UpdateDate]   DATETIME      DEFAULT (getdate()) NOT NULL
);


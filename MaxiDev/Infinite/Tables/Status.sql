CREATE TABLE [Infinite].[Status] (
    [StatusId]   INT            IDENTITY (1, 1) NOT NULL,
    [StatusName] NVARCHAR (50)  NOT NULL,
    [StatusDesc] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([StatusId] ASC)
);


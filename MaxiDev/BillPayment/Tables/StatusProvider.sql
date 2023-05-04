CREATE TABLE [BillPayment].[StatusProvider] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [ProviderId] INT           NULL,
    [StatusId]   INT           NULL,
    [StatusName] VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


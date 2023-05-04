CREATE TABLE [ExRateService].[ServiceLogDetails] (
    [Id]               INT           IDENTITY (1, 1) NOT NULL,
    [Category]         VARCHAR (MAX) NOT NULL,
    [Message]          VARCHAR (MAX) NOT NULL,
    [IdExRateSchedule] INT           NULL,
    [ServiceApplyDate] DATETIME      NULL,
    [DateLog]          DATETIME      NOT NULL,
    CONSTRAINT [PK_ExRateServiceLogDetails] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90)
);


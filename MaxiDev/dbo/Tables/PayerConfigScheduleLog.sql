CREATE TABLE [dbo].[PayerConfigScheduleLog] (
    [IdPayerConfigScheduleLog] INT      IDENTITY (1, 1) NOT NULL,
    [DateOfChange]             DATETIME NOT NULL,
    [IdUserWhoEdited]          INT      NOT NULL,
    [IdPayerConfig]            INT      NOT NULL,
    [StartTime]                TIME (7) NULL,
    [EndTime]                  TIME (7) NULL,
    CONSTRAINT [PK_PayerConfigScheduleLog] PRIMARY KEY CLUSTERED ([IdPayerConfigScheduleLog] ASC)
);


CREATE TABLE [dbo].[CheckProcessorInFail] (
    [ID]                INT NOT NULL,
    [TimesToReportFail] INT NOT NULL,
    [FailCounter]       INT NOT NULL,
    [IsRunning]         BIT NOT NULL,
    CONSTRAINT [PK_CheckProcessorInFail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


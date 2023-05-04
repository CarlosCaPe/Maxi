CREATE TABLE [dbo].[AgentSelectDateException] (
    [idAgent]     INT NOT NULL,
    [MaximumDays] INT NOT NULL,
    UNIQUE NONCLUSTERED ([idAgent] ASC)
);


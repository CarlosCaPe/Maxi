CREATE TABLE [dbo].[AgentTaxIdType] (
    [IdAgentTaxIdType] INT           IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (50) NULL,
    [DateOfLastChange] DATETIME      NULL,
    CONSTRAINT [PK_AgentTaxiIdType] PRIMARY KEY CLUSTERED ([IdAgentTaxIdType] ASC)
);


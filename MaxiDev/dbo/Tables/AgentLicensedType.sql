CREATE TABLE [dbo].[AgentLicensedType] (
    [IdAgentLicensedType] INT           IDENTITY (1, 1) NOT NULL,
    [Name]                VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_AgentLicensedType] PRIMARY KEY CLUSTERED ([IdAgentLicensedType] ASC)
);


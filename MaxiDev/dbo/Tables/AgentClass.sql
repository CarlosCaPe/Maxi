CREATE TABLE [dbo].[AgentClass] (
    [IdAgentClass]     INT            IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (1)   NOT NULL,
    [Description]      NVARCHAR (100) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [ClassPercent]     INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AgentClass] PRIMARY KEY CLUSTERED ([IdAgentClass] ASC) WITH (FILLFACTOR = 90)
);


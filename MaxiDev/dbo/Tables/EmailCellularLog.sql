CREATE TABLE [dbo].[EmailCellularLog] (
    [IdEmailCellularLog] INT            IDENTITY (1, 1) NOT NULL,
    [Number]             NVARCHAR (MAX) NULL,
    [Body]               NVARCHAR (MAX) NULL,
    [Subject]            NVARCHAR (MAX) NULL,
    [DateOfMessage]      DATETIME       NULL,
    [IsSend]             BIT            DEFAULT ((0)) NOT NULL,
    [IsNegative]         BIT            DEFAULT ((0)) NOT NULL,
    [AgentCode]          VARCHAR (MAX)  DEFAULT ('') NOT NULL
);


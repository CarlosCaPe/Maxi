CREATE TABLE [dbo].[SoftgateTerminalIds] (
    [IdSoftgateTerminalId] INT           IDENTITY (1, 1) NOT NULL,
    [StateCode]            NVARCHAR (10) NOT NULL,
    [TerminalId]           NVARCHAR (10) NOT NULL,
    CONSTRAINT [PK_SoftgateTerminalIds] PRIMARY KEY CLUSTERED ([IdSoftgateTerminalId] ASC) WITH (FILLFACTOR = 90)
);


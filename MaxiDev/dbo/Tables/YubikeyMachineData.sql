CREATE TABLE [dbo].[YubikeyMachineData] (
    [IdYubiMachineData] INT           IDENTITY (1, 1) NOT NULL,
    [IdAgent]           INT           NOT NULL,
    [Ethernet]          VARCHAR (MAX) NULL,
    [WiFi]              VARCHAR (MAX) NULL,
    [AgentVersion]      VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_YubikeyMachineData] PRIMARY KEY CLUSTERED ([IdYubiMachineData] ASC)
);


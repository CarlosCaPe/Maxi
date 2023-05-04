CREATE TABLE [WellsFargo].[TransferWFEcheckLogs] (
    [IdTransferWFEcheckLog] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]               INT            NOT NULL,
    [Request]               NVARCHAR (MAX) NULL,
    [RequestDate]           DATETIME       NULL,
    [Response]              NVARCHAR (MAX) NULL,
    [ResponseDate]          DATETIME       NULL,
    [ReasonCode]            NVARCHAR (MAX) NULL,
    [TransID]               NVARCHAR (MAX) NULL,
    [Folio]                 NVARCHAR (MAX) NULL,
    [Endpoint]              NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TransferWFEcheckLogs] PRIMARY KEY CLUSTERED ([IdTransferWFEcheckLog] ASC)
);


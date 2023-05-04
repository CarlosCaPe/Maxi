CREATE TABLE [lunex].[ServiceLogLunex] (
    [IdServiceLogLunex] INT            IDENTITY (1, 1) NOT NULL,
    [Request]           NVARCHAR (MAX) NULL,
    [Response]          NVARCHAR (MAX) NULL,
    [IsSuccess]         BIT            NOT NULL,
    [TransactionID]     BIGINT         NOT NULL,
    [DateLastChange]    DATETIME       NOT NULL,
    CONSTRAINT [PK_ServiceLogLunex] PRIMARY KEY CLUSTERED ([IdServiceLogLunex] ASC)
);


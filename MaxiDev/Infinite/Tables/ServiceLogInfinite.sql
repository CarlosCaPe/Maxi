CREATE TABLE [Infinite].[ServiceLogInfinite] (
    [IdServiceLogInfinite] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Request]              NVARCHAR (MAX) NULL,
    [Response]             NVARCHAR (MAX) NULL,
    [IsSuccess]            BIT            NOT NULL,
    [TransactionId]        BIGINT         NOT NULL,
    [DateLastChange]       DATETIME       NOT NULL,
    PRIMARY KEY CLUSTERED ([IdServiceLogInfinite] ASC)
);


CREATE TABLE [dbo].[TToMobileOperation] (
    [TransferToMobileId]    BIGINT         IDENTITY (1, 1) NOT NULL,
    [TransferId]            INT            NOT NULL,
    [UniqueReferenceNumber] NVARCHAR (200) NOT NULL,
    [CommissionAmount]      MONEY          NULL,
    [TotalAmount]           MONEY          NULL
);


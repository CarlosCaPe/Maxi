CREATE TABLE [dbo].[TransferRequestedOWB] (
    [IdTransferRequestedOWB]  INT IDENTITY (1, 1) NOT NULL,
    [IdTransfer]              INT NULL,
    [IdMoneyBelongToCustomer] INT NULL
);


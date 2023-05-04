CREATE TABLE [dbo].[PretransferRequestedOWB] (
    [IdPretransferRequestedOWB] INT IDENTITY (1, 1) NOT NULL,
    [IdPretransfer]             INT NULL,
    [IdMoneyBelongToCustomer]   INT NULL,
    PRIMARY KEY CLUSTERED ([IdPretransferRequestedOWB] ASC)
);


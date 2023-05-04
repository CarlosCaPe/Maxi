CREATE TABLE [Soporte].[CustomerDepositAccountMigration] (
    [IdCustomerDepositAccountMigration] INT      IDENTITY (1, 1) NOT NULL,
    [IdTransfersCustomerInfoByPayer]    INT      NULL,
    [IdPayerOriginal]                   INT      NULL,
    [IdPayerNew]                        INT      NULL,
    [DateOfChange]                      DATETIME NULL,
    PRIMARY KEY CLUSTERED ([IdCustomerDepositAccountMigration] ASC)
);


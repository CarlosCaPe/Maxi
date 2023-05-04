CREATE TABLE [dbo].[TransfersCustomerInfoByPayer_BAK] (
    [IdTransfersCustomerInfoByPayer] INT            NOT NULL,
    [idCustomer]                     INT            NOT NULL,
    [idPayer]                        INT            NOT NULL,
    [DepositAccountNumber]           NVARCHAR (MAX) NULL,
    [idBeneficiary]                  INT            NOT NULL
);


CREATE TABLE [dbo].[TransfersCustomerInfoByPayer] (
    [IdTransfersCustomerInfoByPayer] INT            IDENTITY (1, 1) NOT NULL,
    [idCustomer]                     INT            NOT NULL,
    [idPayer]                        INT            NOT NULL,
    [DepositAccountNumber]           NVARCHAR (MAX) NULL,
    [idBeneficiary]                  INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TransfersCustomerInfoByPayer] PRIMARY KEY CLUSTERED ([IdTransfersCustomerInfoByPayer] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_TransfersCustomerInfoByPayer_idCustomer_idPayer_idBeneficiary]
    ON [dbo].[TransfersCustomerInfoByPayer]([idCustomer] ASC, [idPayer] ASC, [idBeneficiary] ASC);


CREATE TABLE [dbo].[TransferPayInfo] (
    [IdTransferPayInfo]   INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]          INT            NOT NULL,
    [ClaimCode]           NVARCHAR (50)  NOT NULL,
    [IdGateway]           INT            NOT NULL,
    [DateOfPayment]       DATETIME       NOT NULL,
    [BranchCode]          NVARCHAR (50)  NOT NULL,
    [BeneficiaryIdNumber] NVARCHAR (100) NOT NULL,
    [BeneficiaryIdType]   NVARCHAR (100) NOT NULL,
    [IdBranch]            INT            NULL,
    CONSTRAINT [PK_TransferPayInfo] PRIMARY KEY CLUSTERED ([IdTransferPayInfo] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_IdTransfer_IdTransferPayInfo_DateOfPayment_BranchCode]
    ON [dbo].[TransferPayInfo]([IdTransfer] ASC)
    INCLUDE([IdTransferPayInfo], [DateOfPayment], [BranchCode]) WITH (FILLFACTOR = 90);


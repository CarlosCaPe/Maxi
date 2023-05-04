CREATE TABLE [BillPayment].[MaskForBillers] (
    [IdMaskBiller] INT            IDENTITY (1, 1) NOT NULL,
    [IdBiller]     INT            NOT NULL,
    [Length]       INT            NULL,
    [Mask]         NVARCHAR (100) DEFAULT ('') NOT NULL,
    [CheckType]    NVARCHAR (100) DEFAULT ('') NOT NULL,
    [CheckDigits]  NVARCHAR (100) DEFAULT ('') NOT NULL,
    [OCRPosition]  NVARCHAR (100) DEFAULT ('') NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_MaskForBillers_IdBiller]
    ON [BillPayment].[MaskForBillers]([IdBiller] ASC)
    INCLUDE([Length]);


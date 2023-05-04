CREATE TABLE [BillPayment].[StateForBillers] (
    [IdStateBiller] INT IDENTITY (1, 1) NOT NULL,
    [IdBiller]      INT NOT NULL,
    [IdState]       INT NOT NULL,
    [IdFee]         INT NOT NULL,
    [IdCommission]  INT NOT NULL,
    [IDStatus]      INT NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_StateForBillers_IdBiller_IdState]
    ON [BillPayment].[StateForBillers]([IdBiller] ASC, [IdState] ASC)
    INCLUDE([IdFee], [IdCommission]);


GO
CREATE NONCLUSTERED INDEX [IX_StateForBillers_IdState_IDStatus]
    ON [BillPayment].[StateForBillers]([IdState] ASC, [IDStatus] ASC)
    INCLUDE([IdBiller]);


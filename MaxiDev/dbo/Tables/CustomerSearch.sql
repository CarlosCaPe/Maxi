CREATE TABLE [dbo].[CustomerSearch] (
    [IdCustomerSeach] BIGINT          IDENTITY (1, 1) NOT NULL,
    [IdCustomer]      BIGINT          NOT NULL,
    [IdAgent]         INT             NOT NULL,
    [IdStatus]        INT             NOT NULL,
    [FullNameRaw]     NVARCHAR (1500) NULL,
    [FullNameClean]   NVARCHAR (1500) NULL,
    [MetaPhoneSplit]  NVARCHAR (1500) NULL,
    [PhoneNumber]     NVARCHAR (20)   NULL,
    [CelullarNumber]  NVARCHAR (20)   NULL,
    CONSTRAINT [UQ_CustomerSearch_IdCustomer] UNIQUE NONCLUSTERED ([IdCustomer] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CustomerSearch_IdStatus_IdAgent]
    ON [dbo].[CustomerSearch]([IdStatus] ASC, [IdAgent] ASC)
    INCLUDE([IdCustomer], [FullNameClean], [MetaPhoneSplit]);


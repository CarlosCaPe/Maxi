CREATE TABLE [dbo].[CustomerSearch2] (
    [IdCustomerSeach] BIGINT          IDENTITY (1, 1) NOT NULL,
    [IdCustomer]      BIGINT          NOT NULL,
    [IdAgent]         INT             NOT NULL,
    [IdStatus]        INT             NOT NULL,
    [FullNameRaw]     NVARCHAR (1500) NULL,
    [FullNameAppend]  NVARCHAR (1500) NULL,
    [FullNameClean]   NVARCHAR (1500) NULL,
    [MetaPhoneFull]   NVARCHAR (1500) NULL,
    [MetaPhoneSplit]  NVARCHAR (1500) NULL,
    CONSTRAINT [UQ_CustomerSearch_IdCustomer2] UNIQUE NONCLUSTERED ([IdCustomer] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CustomerSearch_IdStatus_IdAgent2]
    ON [dbo].[CustomerSearch2]([IdStatus] ASC, [IdAgent] ASC)
    INCLUDE([IdCustomer], [FullNameClean], [MetaPhoneSplit]);


CREATE TABLE [dbo].[BillAccounts] (
    [IdBillAccounts]             INT            IDENTITY (1, 1) NOT NULL,
    [AccountNumber]              NVARCHAR (MAX) NULL,
    [IdProductsByProvider]       INT            NOT NULL,
    [IdCustomer]                 INT            NOT NULL,
    [BillerDescription]          NVARCHAR (MAX) NULL,
    [LastChanges_LastUserChange] NVARCHAR (MAX) NULL,
    [LastChanges_LastDateChange] DATETIME       NOT NULL,
    [LastChanges_LastIpChange]   NVARCHAR (MAX) NULL,
    [LastChanges_LastNoteChange] NVARCHAR (MAX) NULL,
    [AltAccountNumber]           NVARCHAR (MAX) NULL,
    [CustomField1]               NVARCHAR (MAX) NULL,
    [CustomField2]               NVARCHAR (MAX) NULL,
    [AltAccountNumberLabel]      NVARCHAR (MAX) NULL,
    [CustomField1Label]          NVARCHAR (MAX) NULL,
    [CustomField2Label]          NVARCHAR (MAX) NULL,
    [OnBehalf_LastName]          NVARCHAR (MAX) NULL,
    [OnBehalf_MiddleName]        NVARCHAR (MAX) NULL,
    [OnBehalf_FirstName]         NVARCHAR (MAX) NULL,
    [OnBehalf_Occupation]        NVARCHAR (MAX) NULL,
    [OnBehalf_Address]           NVARCHAR (MAX) NULL,
    [OnBehalf_City]              NVARCHAR (MAX) NULL,
    [OnBehalf_State]             NVARCHAR (MAX) NULL,
    [OnBehalf_Zip]               NVARCHAR (MAX) NULL,
    [OnBehalf_Telephone]         NVARCHAR (MAX) NULL,
    [OnBehalf_IdType]            INT            NULL,
    [OnBehalf_IdIssuer]          NVARCHAR (MAX) NULL,
    [OnBehalf_IdNumber]          NVARCHAR (MAX) NULL,
    [OnBehalf_Ssn]               NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdBillAccounts] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [BillAccount_SelectedCustomer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer])
);


GO
CREATE NONCLUSTERED INDEX [IX_BillAccounts_IdCustomer]
    ON [dbo].[BillAccounts]([IdCustomer] ASC);


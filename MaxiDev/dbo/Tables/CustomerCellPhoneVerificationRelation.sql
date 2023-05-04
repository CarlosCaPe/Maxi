CREATE TABLE [dbo].[CustomerCellPhoneVerificationRelation] (
    [IdCustomerCellPhoneVerificationRelation] INT      IDENTITY (1, 1) NOT NULL,
    [IdCellPhoneVerification]                 INT      NOT NULL,
    [IdCustomer]                              INT      NULL,
    [OldCustomer]                             XML      NULL,
    [CreationDate]                            DATETIME NOT NULL,
    [EnterByIdUser]                           INT      NOT NULL,
    CONSTRAINT [PK_CustomerCellPhoneVerificationRelation] PRIMARY KEY CLUSTERED ([IdCustomerCellPhoneVerificationRelation] ASC),
    CONSTRAINT [FK_CustomerCellPhoneVerificationRelation_CellPhoneVerification] FOREIGN KEY ([IdCellPhoneVerification]) REFERENCES [dbo].[CellPhoneVerification] ([IdCellPhoneVerification]),
    CONSTRAINT [FK_CustomerCellPhoneVerificationRelation_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer])
);


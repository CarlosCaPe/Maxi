CREATE TABLE [dbo].[StatusCustomerSAR] (
    [IdCustomer]     INT      NOT NULL,
    [IdUser]         INT      NOT NULL,
    [StatusSAR]      BIT      NULL,
    [DataLastChange] DATETIME NULL,
    [IdStatusChange] BIGINT   IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_StatusCustomerSAR] PRIMARY KEY CLUSTERED ([IdStatusChange] ASC),
    CONSTRAINT [FK_StatusCustomerSAR_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_StatusCustomerSAR_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


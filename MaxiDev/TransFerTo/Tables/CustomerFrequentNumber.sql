CREATE TABLE [TransFerTo].[CustomerFrequentNumber] (
    [IdCustomerFrequentNumber] INT            IDENTITY (1, 1) NOT NULL,
    [IdCustomer]               INT            NOT NULL,
    [BeneficiaryCelullar]      NVARCHAR (MAX) NOT NULL,
    [NickName]                 NVARCHAR (MAX) NOT NULL,
    [IdGenericStatus]          INT            NOT NULL,
    [EnterByIdUser]            INT            NOT NULL,
    [CreationDate]             DATETIME       NOT NULL,
    [DateOfLastChange]         DATETIME       NOT NULL,
    CONSTRAINT [PK_CustomerFrequentNumber] PRIMARY KEY CLUSTERED ([IdCustomerFrequentNumber] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CustomerFrequentNumber_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_CustomerFrequentNumber_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_CustomerFrequentNumber_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


CREATE TABLE [dbo].[PaymentMethod] (
    [IdPaymentMethod]  INT            IDENTITY (1, 1) NOT NULL,
    [PaymentMethod]    NVARCHAR (100) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_PaymentMethod] PRIMARY KEY CLUSTERED ([IdPaymentMethod] ASC) WITH (FILLFACTOR = 90)
);


CREATE TABLE [dbo].[PayerConfigCommission] (
    [IdPayerConfigCommission]     INT      IDENTITY (1, 1) NOT NULL,
    [IdPayerConfig]               INT      NOT NULL,
    [DateOfPayerConfigCommission] DATETIME NOT NULL,
    [DateOfLastChange]            DATETIME NOT NULL,
    [EnterByIdUser]               INT      NOT NULL,
    [CommissionOld]               MONEY    NOT NULL,
    [CommissionNew]               MONEY    NOT NULL,
    [Active]                      BIT      NOT NULL,
    CONSTRAINT [PK_PayerConfigCommission] PRIMARY KEY CLUSTERED ([IdPayerConfigCommission] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PayerConfigCommission_PayerConfig] FOREIGN KEY ([IdPayerConfig]) REFERENCES [dbo].[PayerConfig] ([IdPayerConfig]),
    CONSTRAINT [FK_PayerConfigCommission_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_PayerConfigCommission_IdPayerConfig_DateOfPayerConfigCommission]
    ON [dbo].[PayerConfigCommission]([IdPayerConfig] ASC, [DateOfPayerConfigCommission] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PayerConfigCommission_Active_DateOfPayerConfigCommission]
    ON [dbo].[PayerConfigCommission]([Active] ASC, [DateOfPayerConfigCommission] ASC)
    INCLUDE([IdPayerConfig], [CommissionNew]);


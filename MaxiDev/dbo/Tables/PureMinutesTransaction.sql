CREATE TABLE [dbo].[PureMinutesTransaction] (
    [IdPureMinutes]           INT            IDENTITY (1, 1) NOT NULL,
    [IdUser]                  INT            NOT NULL,
    [IdAgent]                 INT            NOT NULL,
    [DateOfTransaction]       DATETIME       NOT NULL,
    [DateOfLastChange]        DATETIME       NOT NULL,
    [ReceiveAccountNumber]    NVARCHAR (100) NULL,
    [IdCustomer]              INT            NOT NULL,
    [SenderName]              NVARCHAR (MAX) NOT NULL,
    [SenderFirstLastName]     NVARCHAR (MAX) NOT NULL,
    [SenderSecondLastName]    NVARCHAR (MAX) NOT NULL,
    [SenderAddress]           NVARCHAR (MAX) NOT NULL,
    [SenderCity]              NVARCHAR (MAX) NOT NULL,
    [SenderState]             NVARCHAR (MAX) NOT NULL,
    [SenderCountry]           NVARCHAR (MAX) NOT NULL,
    [SenderZipCode]           NVARCHAR (MAX) NOT NULL,
    [SenderPhoneNumber]       NVARCHAR (MAX) NULL,
    [PromoCode]               NVARCHAR (MAX) NULL,
    [ReceiveAmount]           MONEY          NOT NULL,
    [Fee]                     MONEY          NULL,
    [AgentCommission]         MONEY          NOT NULL,
    [CorpCommission]          MONEY          NOT NULL,
    [Status]                  INT            NOT NULL,
    [AgentReferenceNumber]    NVARCHAR (MAX) NULL,
    [LastReturnCode]          NVARCHAR (MAX) NULL,
    [Request]                 NVARCHAR (MAX) NULL,
    [Response]                NVARCHAR (MAX) NULL,
    [PromocodeResponse]       NVARCHAR (MAX) NULL,
    [PureMinutesTransID]      NVARCHAR (MAX) NULL,
    [PureMinutesUserID]       NVARCHAR (MAX) NULL,
    [ConfirmationCode]        NVARCHAR (MAX) NULL,
    [ActualReceiveDateTime]   DATETIME       NULL,
    [Balance]                 MONEY          NULL,
    [CreditForPromoCode]      MONEY          NULL,
    [CancelIdUser]            INT            NULL,
    [CancelDateOfTransaction] DATETIME       NULL,
    [Bonification]            BIT            DEFAULT ((0)) NOT NULL,
    [AccessNumber]            NVARCHAR (MAX) NULL,
    [IdTransfer]              INT            NULL,
    [IdProductTransfer]       BIGINT         DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__PureMinu__889C36BF31E24B85] PRIMARY KEY CLUSTERED ([IdPureMinutes] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_PureMinutesTransaction_ReceiveAccountNumber]
    ON [dbo].[PureMinutesTransaction]([ReceiveAccountNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PureMinutesTransaction_IdProductTransfer_ReceiveAccountNumber]
    ON [dbo].[PureMinutesTransaction]([IdProductTransfer] ASC, [ReceiveAccountNumber] ASC)
    INCLUDE([SenderFirstLastName], [SenderName], [SenderSecondLastName]);


GO
CREATE NONCLUSTERED INDEX [ix_PureMinutesTransactionStatusIdTransfer]
    ON [dbo].[PureMinutesTransaction]([Status] ASC, [IdTransfer] ASC);


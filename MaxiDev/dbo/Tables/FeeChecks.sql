CREATE TABLE [dbo].[FeeChecks] (
    [IdFeeChecks]      INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]          INT            NOT NULL,
    [AllowChecks]      BIT            NOT NULL,
    [FeeName]          NVARCHAR (MAX) NOT NULL,
    [TransactionFee]   MONEY          NOT NULL,
    [ReturnCheckFee]   MONEY          NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [FeeCheckScanner]  MONEY          NULL,
    CONSTRAINT [PK_FeeChecks] PRIMARY KEY CLUSTERED ([IdFeeChecks] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_FeeChecks_IdAgent]
    ON [dbo].[FeeChecks]([IdAgent] ASC);


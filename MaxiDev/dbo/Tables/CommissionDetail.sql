CREATE TABLE [dbo].[CommissionDetail] (
    [IdCommissionDetail]              INT            IDENTITY (1, 1) NOT NULL,
    [IdCommission]                    INT            NOT NULL,
    [FromAmount]                      MONEY          NOT NULL,
    [ToAmount]                        MONEY          NOT NULL,
    [AgentCommissionInPercentage]     DECIMAL (5, 2) NOT NULL,
    [CorporateCommissionInPercentage] DECIMAL (5, 2) NOT NULL,
    [DateOfLastChange]                DATETIME       NOT NULL,
    [EnterByIdUser]                   INT            NOT NULL,
    [ExtraAmount]                     MONEY          NOT NULL,
    CONSTRAINT [PK_CommissionDetail] PRIMARY KEY CLUSTERED ([IdCommissionDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CommissionDetail_Commission] FOREIGN KEY ([IdCommission]) REFERENCES [dbo].[Commission] ([IdCommission])
);


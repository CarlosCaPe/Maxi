CREATE TABLE [dbo].[CommissionDetailByOtherProducts] (
    [IdCommissionDetailByProvider]    INT            IDENTITY (1, 1) NOT NULL,
    [IdCommissionByOtherProducts]     INT            NOT NULL,
    [FromAmount]                      MONEY          NOT NULL,
    [ToAmount]                        MONEY          NOT NULL,
    [AgentCommissionInPercentage]     DECIMAL (5, 2) NOT NULL,
    [CorporateCommissionInPercentage] DECIMAL (5, 2) NOT NULL,
    [DateOfLastChange]                DATETIME       NOT NULL,
    [EnterByIdUser]                   INT            NOT NULL,
    [ExtraAmount]                     MONEY          NOT NULL,
    [BillerSpecific]                  DECIMAL (5, 2) DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161214-113318]
    ON [dbo].[CommissionDetailByOtherProducts]([IdCommissionDetailByProvider] ASC, [IdCommissionByOtherProducts] ASC);


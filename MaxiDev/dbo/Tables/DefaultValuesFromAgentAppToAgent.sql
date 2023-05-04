CREATE TABLE [dbo].[DefaultValuesFromAgentAppToAgent] (
    [IdAgentType]                        INT            NOT NULL,
    [IdAgentStatus]                      INT            NOT NULL,
    [IdAgentPaymentSchema]               INT            NOT NULL,
    [CreditAmount]                       MONEY          NOT NULL,
    [Folio]                              INT            NOT NULL,
    [AmountRequiredToAskId]              MONEY          NOT NULL,
    [SwitchCommission]                   BIT            NOT NULL,
    [SwitchExrate]                       BIT            NOT NULL,
    [CommissionTop]                      MONEY          NOT NULL,
    [CommissionBottom]                   MONEY          NOT NULL,
    [ExrateTop]                          MONEY          NOT NULL,
    [ExrateBottom]                       MONEY          NOT NULL,
    [ShowAgentProfitWhenSendingTransfer] BIT            NOT NULL,
    [AgentBussinesType]                  NVARCHAR (MAX) NOT NULL,
    [AmountForClassF]                    MONEY          NULL,
    [IdAgentClass]                       INT            NULL
);


CREATE TABLE [dbo].[CreditLimitHistory] (
    [IdCreditLimitHistory] INT          IDENTITY (1, 1) NOT NULL,
    [IdAgent]              INT          NULL,
    [CreditLimit]          DECIMAL (18) NULL,
    [DateOfCreation]       DATETIME     NULL,
    [EnteredByIdUser]      INT          NULL,
    CONSTRAINT [PK_CreditLimitHistory] PRIMARY KEY CLUSTERED ([IdCreditLimitHistory] ASC) WITH (FILLFACTOR = 90)
);


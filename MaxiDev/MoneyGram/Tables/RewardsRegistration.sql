CREATE TABLE [MoneyGram].[RewardsRegistration] (
    [Country]              VARCHAR (200) NULL,
    [ProgramType]          VARCHAR (200) NULL,
    [CardType]             VARCHAR (200) NULL,
    [AllowPrePrintedCards] BIT           NULL,
    [AllowStandardCards]   BIT           NULL,
    [DateOfLastChange]     DATETIME      NULL,
    [CreationDate]         DATETIME      NOT NULL
);


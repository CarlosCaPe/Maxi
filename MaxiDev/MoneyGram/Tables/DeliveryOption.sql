CREATE TABLE [MoneyGram].[DeliveryOption] (
    [DeliveryOptionID]   INT           NOT NULL,
    [DeliveryOption]     VARCHAR (30)  NOT NULL,
    [DeliveryOptionName] VARCHAR (200) NOT NULL,
    [DssOption]          BIT           NOT NULL,
    [DateOfLastChange]   DATETIME      NULL,
    [CreationDate]       DATETIME      NOT NULL,
    CONSTRAINT [PK_MoneyGram_DeliveryOption] PRIMARY KEY CLUSTERED ([DeliveryOptionID] ASC),
    CONSTRAINT [UQ_MoneyGram_DeliveryOption] UNIQUE NONCLUSTERED ([DeliveryOption] ASC)
);


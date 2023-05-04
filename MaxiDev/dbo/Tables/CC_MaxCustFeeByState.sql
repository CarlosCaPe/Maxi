CREATE TABLE [dbo].[CC_MaxCustFeeByState] (
    [IdMaxCustFeeByState] INT   IDENTITY (1, 1) NOT NULL,
    [IdState]             INT   NOT NULL,
    [MaxPercFee]          MONEY NOT NULL,
    [MaxFixedFee]         MONEY NOT NULL,
    [MaxCheckAmount]      MONEY NOT NULL,
    CONSTRAINT [PK_CC_MaxCustFeeByState] PRIMARY KEY CLUSTERED ([IdMaxCustFeeByState] ASC)
);


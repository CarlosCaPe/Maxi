CREATE TABLE [dbo].[CC_AgFees] (
    [IdAgCustFee]         INT      IDENTITY (1, 1) NOT NULL,
    [ACF_DateCreated]     DATETIME CONSTRAINT [DF_CC_AgFees_ACCF_DateCreated] DEFAULT (getdate()) NOT NULL,
    [ACF_IdUserCreated]   INT      NOT NULL,
    [IdAgent]             INT      NOT NULL,
    [IdCheckType]         INT      NULL,
    [ACF_CheckAmountFrom] MONEY    NOT NULL,
    [ACF_CheckAmountTo]   MONEY    NOT NULL,
    [ACF_FeeFixed]        MONEY    CONSTRAINT [DF_CC_AgFees_ACCF_FeeFixed] DEFAULT ((0)) NOT NULL,
    [ACF_FeePerc]         MONEY    CONSTRAINT [DF_CC_AgFees_ACCF_FeePerc] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CC_AgFees] PRIMARY KEY CLUSTERED ([IdAgCustFee] ASC)
);


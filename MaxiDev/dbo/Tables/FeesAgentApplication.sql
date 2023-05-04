CREATE TABLE [dbo].[FeesAgentApplication] (
    [IdFeeAgentApplication] BIGINT IDENTITY (1, 1) NOT NULL,
    [IdCountry]             INT    NOT NULL,
    [PercentageFee]         INT    NOT NULL,
    [IdAgentApplication]    INT    NOT NULL,
    CONSTRAINT [FeesAgentApplication_pk] PRIMARY KEY NONCLUSTERED ([IdFeeAgentApplication] ASC)
);


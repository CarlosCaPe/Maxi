CREATE TABLE [dbo].[RefExRateByGroup] (
    [IdRefExRateByGroup] INT          IDENTITY (1, 1) NOT NULL,
    [IdAgent]            INT          NULL,
    [IdPayer]            INT          NULL,
    [IdAgentSchema]      INT          NULL,
    [IdCountryCurrency]  INT          NULL,
    [RefExRateByGroup]   MONEY        NULL,
    [DateOfLastChange]   DATETIME     NULL,
    [DifRefExRate]       VARCHAR (10) NULL,
    CONSTRAINT [PK_RefExRateByGroup] PRIMARY KEY CLUSTERED ([IdRefExRateByGroup] ASC)
);


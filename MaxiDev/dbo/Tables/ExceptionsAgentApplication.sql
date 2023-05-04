CREATE TABLE [dbo].[ExceptionsAgentApplication] (
    [IdExceptionAgentApplication] BIGINT IDENTITY (1, 1) NOT NULL,
    [IdCountry]                   INT    NOT NULL,
    [IdPayer]                     INT    NOT NULL,
    [ExceptionAgentFee]           INT    NULL,
    [IdAgentApplication]          INT    NOT NULL,
    CONSTRAINT [ExceptionsAgentApplication_pk] PRIMARY KEY NONCLUSTERED ([IdExceptionAgentApplication] ASC)
);


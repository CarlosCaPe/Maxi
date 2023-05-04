CREATE TABLE [dbo].[XAgentKYCRules] (
    [IdAgentRules]            INT            IDENTITY (1, 1) NOT NULL,
    [NameInSpanish]           NVARCHAR (MAX) NULL,
    [NameInEnglish]           VARCHAR (MAX)  NULL,
    [MessageInSpanish]        NVARCHAR (MAX) NULL,
    [MessageInEnglish]        NVARCHAR (MAX) NULL,
    [StoreProcToEvaluateRule] NVARCHAR (MAX) NULL,
    [IdGenericStatus]         INT            NULL
);


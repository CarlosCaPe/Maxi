CREATE TABLE [dbo].[SpecialCommissionRuleLog] (
    [IdLog]                   INT           IDENTITY (1, 1) NOT NULL,
    [IdSpecialCommissionRule] INT           NULL,
    [IdUserRequestedBy]       INT           NOT NULL,
    [IdUserAuthorizer]        INT           NOT NULL,
    [IdUserAuthorizedBy]      INT           NULL,
    [Description]             VARCHAR (MAX) NOT NULL,
    [Note]                    VARCHAR (MAX) NOT NULL,
    [BeginDate]               DATE          NOT NULL,
    [EndDate]                 DATE          NULL,
    [IdAgent]                 INT           NULL,
    [IdCountry]               INT           NULL,
    [IdOwner]                 INT           NULL,
    [ApplyForTransaction]     BIT           NOT NULL,
    [IdGenericStatus]         INT           NOT NULL,
    [DateOfLastChange]        DATETIME      NOT NULL,
    [EnterByIdUser]           INT           NOT NULL,
    CONSTRAINT [PK_SpecialCommissionRuleLog] PRIMARY KEY CLUSTERED ([IdLog] ASC)
);


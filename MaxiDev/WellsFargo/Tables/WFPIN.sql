CREATE TABLE [WellsFargo].[WFPIN] (
    [IdWFPIN]          INT             IDENTITY (1, 1) NOT NULL,
    [IdCarrier]        INT             NULL,
    [CelullarNumber]   NVARCHAR (1000) NULL,
    [Email]            NVARCHAR (1000) NULL,
    [PIN]              INT             NOT NULL,
    [EnterByIdUser]    INT             NOT NULL,
    [CreationDate]     DATETIME        NOT NULL,
    [DateOfLastChange] DATETIME        NOT NULL,
    [IdGenericStatus]  INT             NOT NULL,
    CONSTRAINT [PK_WFPIN] PRIMARY KEY CLUSTERED ([IdWFPIN] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentWFPIN_Carrier] FOREIGN KEY ([IdCarrier]) REFERENCES [dbo].[Carriers] ([IdCarrier]),
    CONSTRAINT [FK_AgentWFPIN_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_AgentWFPIN_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


CREATE TABLE [WellsFargo].[WFConfig] (
    [IdWFConfig]          INT             IDENTITY (1, 1) NOT NULL,
    [ForService]          NVARCHAR (1000) NOT NULL,
    [MerchId]             NVARCHAR (MAX)  NOT NULL,
    [Key]                 NVARCHAR (MAX)  NOT NULL,
    [DateOfInitOperation] DATETIME        NOT NULL,
    [DateOfEndOperation]  DATETIME        NOT NULL,
    [EnterByIDUser]       INT             NOT NULL,
    [DateOfCreation]      DATETIME        NOT NULL,
    [DateOfLastChange]    DATETIME        NOT NULL,
    [IdGenericStatus]     INT             NOT NULL,
    [StateCode]           VARCHAR (5)     NULL,
    CONSTRAINT [PK_WFConfig] PRIMARY KEY CLUSTERED ([IdWFConfig] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_WFConfig_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_WFConfig_User] FOREIGN KEY ([EnterByIDUser]) REFERENCES [dbo].[Users] ([IdUser])
);


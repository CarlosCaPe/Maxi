CREATE TABLE [lunex].[Login] (
    [IdLogin]          INT            IDENTITY (1, 1) NOT NULL,
    [IdUser]           INT            NOT NULL,
    [Login]            NVARCHAR (MAX) NULL,
    [ExternalID]       NVARCHAR (MAX) NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [DateOfCreation]   DATETIME       NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [IdGenericStatus]  INT            NOT NULL,
    CONSTRAINT [PK_AgentCredential] PRIMARY KEY CLUSTERED ([IdLogin] ASC),
    CONSTRAINT [FK_LunexLogin_OPStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_LunexLogin_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_LunexLogin_User2] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


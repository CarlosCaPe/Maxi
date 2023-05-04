CREATE TABLE [dbo].[PosTerminal] (
    [IdPosTerminal]   INT           IDENTITY (1, 1) NOT NULL,
    [SerialNumber]    VARCHAR (100) NOT NULL,
    [MAC]             VARCHAR (100) NOT NULL,
    [DeviceType]      VARCHAR (100) NOT NULL,
    [OSVersion]       VARCHAR (100) NOT NULL,
    [IdAsset]         VARCHAR (100) NULL,
    [IdGenericStatus] INT           NOT NULL,
    [CreationDate]    DATETIME      NOT NULL,
    [IdUser]          INT           NOT NULL,
    [TerminalId]      VARCHAR (100) NULL,
    CONSTRAINT [PK_PosTerminal] PRIMARY KEY CLUSTERED ([IdPosTerminal] ASC),
    CONSTRAINT [FK_PosTerminal_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_PosTerminal_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [UQ_PosTerminal_MAC] UNIQUE NONCLUSTERED ([MAC] ASC),
    CONSTRAINT [UQ_PosTerminal_SerialNumber] UNIQUE NONCLUSTERED ([SerialNumber] ASC)
);


CREATE TABLE [dbo].[ReasonForCancel] (
    [IdReasonForCancel]  INT            IDENTITY (1, 1) NOT NULL,
    [Reason]             NVARCHAR (MAX) NULL,
    [IdGenericStatus]    INT            NULL,
    [ReturnAllComission] BIT            NULL,
    [CreationDate]       DATETIME       NULL,
    [DateOfLastChange]   DATETIME       NULL,
    [EnterByIdUser]      INT            NULL,
    [ReasonEn]           NVARCHAR (MAX) DEFAULT ('') NOT NULL,
    [IdGateway]          INT            NULL,
    CONSTRAINT [PK_ReasonForCancel] PRIMARY KEY CLUSTERED ([IdReasonForCancel] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ReasonForCancel_Gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_ReasonForCancel_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_ReasonForCancel_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


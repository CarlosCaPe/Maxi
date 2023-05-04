CREATE TABLE [dbo].[CheckHolds] (
    [IdCheckHold]      INT      IDENTITY (1, 1) NOT NULL,
    [IdCheck]          INT      NOT NULL,
    [IdStatus]         INT      NOT NULL,
    [IsReleased]       BIT      NULL,
    [DateOfValidation] DATETIME NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    [EnterByIdUser]    INT      NOT NULL,
    CONSTRAINT [PK_CheckHolds] PRIMARY KEY CLUSTERED ([IdCheckHold] ASC),
    CONSTRAINT [FK_CheckHolds_Status] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[Status] ([IdStatus]),
    CONSTRAINT [FK_CheckHolds_Transfer] FOREIGN KEY ([IdCheck]) REFERENCES [dbo].[Checks] ([IdCheck])
);


GO
CREATE NONCLUSTERED INDEX [ix_CheckHolds_IdStatus_IsReleased_includes]
    ON [dbo].[CheckHolds]([IdStatus] ASC, [IsReleased] ASC)
    INCLUDE([IdCheck]);


GO
CREATE NONCLUSTERED INDEX [ix_CheckHolds_IdCheck_IsReleased]
    ON [dbo].[CheckHolds]([IdCheck] ASC, [IsReleased] ASC);


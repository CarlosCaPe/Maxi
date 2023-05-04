CREATE TABLE [dbo].[DenyListBeneficiary] (
    [IdDenyListBeneficiary] INT            IDENTITY (1, 1) NOT NULL,
    [IdBeneficiary]         INT            NOT NULL,
    [DateInToList]          DATETIME       NOT NULL,
    [DateOutFromList]       DATETIME       NULL,
    [IdUserCreater]         INT            NOT NULL,
    [IdUserDeleter]         INT            NULL,
    [NoteInToList]          NVARCHAR (MAX) NOT NULL,
    [NoteOutFromList]       NVARCHAR (MAX) NULL,
    [IdGenericStatus]       INT            NOT NULL,
    [EnterByIdUser]         INT            NULL,
    [DateOfLastChange]      DATETIME       NULL,
    CONSTRAINT [PK_DenyListBeneficiary] PRIMARY KEY CLUSTERED ([IdDenyListBeneficiary] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_DenyListBeneficiary_Beneficiary] FOREIGN KEY ([IdBeneficiary]) REFERENCES [dbo].[Beneficiary] ([IdBeneficiary]),
    CONSTRAINT [FK_DenyListBeneficiary_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);


GO
CREATE NONCLUSTERED INDEX [DenyListBeneficiary_GenericStatusIdCustomer]
    ON [dbo].[DenyListBeneficiary]([IdGenericStatus] ASC)
    INCLUDE([IdDenyListBeneficiary], [IdBeneficiary]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ix_DenyListBeneficiary_IdBeneficiary_IdGenericStatus_includes]
    ON [dbo].[DenyListBeneficiary]([IdBeneficiary] ASC, [IdGenericStatus] ASC)
    INCLUDE([IdDenyListBeneficiary]);


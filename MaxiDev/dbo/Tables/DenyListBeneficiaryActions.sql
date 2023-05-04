CREATE TABLE [dbo].[DenyListBeneficiaryActions] (
    [IdDenyListBeneficiaryAction] INT            IDENTITY (1, 1) NOT NULL,
    [IdDenyListBeneficiary]       INT            NOT NULL,
    [IdKYCAction]                 INT            NOT NULL,
    [MessageInEnglish]            NVARCHAR (MAX) NOT NULL,
    [MessageInSpanish]            NVARCHAR (MAX) NOT NULL,
    [IdTypeRequired]              BIT            DEFAULT ((0)) NOT NULL,
    [IdNumberRequired]            BIT            DEFAULT ((0)) NOT NULL,
    [IdExpirationDateRequired]    BIT            DEFAULT ((0)) NOT NULL,
    [IdStateCountryRequired]      BIT            DEFAULT ((0)) NOT NULL,
    [DateOfBirthRequired]         BIT            DEFAULT ((0)) NOT NULL,
    [OccupationRequired]          BIT            DEFAULT ((0)) NOT NULL,
    [SSNRequired]                 BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DenyListBeneficiaryActions] PRIMARY KEY CLUSTERED ([IdDenyListBeneficiaryAction] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_DenyListBeneficiaryActions_DenyListBeneficiary] FOREIGN KEY ([IdDenyListBeneficiary]) REFERENCES [dbo].[DenyListBeneficiary] ([IdDenyListBeneficiary]),
    CONSTRAINT [FK_DenyListBeneficiaryActions_KYCAction] FOREIGN KEY ([IdKYCAction]) REFERENCES [dbo].[KYCAction] ([IdKYCAction])
);


GO
CREATE NONCLUSTERED INDEX [ix_DenyListBeneficiaryActions_IdDenyListBeneficiary_includes]
    ON [dbo].[DenyListBeneficiaryActions]([IdDenyListBeneficiary] ASC)
    INCLUDE([IdKYCAction], [MessageInEnglish], [MessageInSpanish]);


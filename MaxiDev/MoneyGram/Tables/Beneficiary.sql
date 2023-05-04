CREATE TABLE [MoneyGram].[Beneficiary] (
    [IdBeneficiaryRelation]  BIGINT       NOT NULL,
    [IdBeneficiary]          INT          NOT NULL,
    [IdBeneficiaryMoneyGram] VARCHAR (20) NOT NULL,
    [CreationDate]           DATETIME     NOT NULL,
    [EnterByIdUser]          INT          NOT NULL,
    CONSTRAINT [PK_MoneyGramBeneficiary] PRIMARY KEY CLUSTERED ([IdBeneficiaryRelation] ASC),
    CONSTRAINT [FK_MoneyGramBeneficiary_Beneficiary] FOREIGN KEY ([IdBeneficiary]) REFERENCES [dbo].[Beneficiary] ([IdBeneficiary]),
    CONSTRAINT [UQ_MoneyGramBeneficiary_IdBeneficiary] UNIQUE NONCLUSTERED ([IdBeneficiary] ASC),
    CONSTRAINT [UQ_MoneyGramBeneficiary_IdBeneficiaryMoneyGram] UNIQUE NONCLUSTERED ([IdBeneficiaryMoneyGram] ASC)
);


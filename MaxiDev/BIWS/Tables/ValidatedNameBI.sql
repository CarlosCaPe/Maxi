CREATE TABLE [BIWS].[ValidatedNameBI] (
    [IdValidateName]       INT            IDENTITY (1, 1) NOT NULL,
    [DateTime]             DATETIME       NOT NULL,
    [IdAgent]              INT            NOT NULL,
    [DepositAccountNumber] NVARCHAR (250) NOT NULL,
    [NameBeneficiaryMAXI]  NVARCHAR (250) NOT NULL,
    [NameBeneficiaryBI]    NVARCHAR (250) NOT NULL,
    [MatchPercentage]      INT            NOT NULL,
    CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED ([IdValidateName] ASC)
);


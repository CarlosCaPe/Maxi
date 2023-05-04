CREATE TABLE [dbo].[StatusBeneficiarySAR] (
    [IdBeneficiary]  INT      NOT NULL,
    [IdUser]         INT      NOT NULL,
    [StatusSAR]      BIT      NULL,
    [DataLastChange] DATETIME NULL,
    [IdStatusChange] BIGINT   IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_StatusBeneficiarySAR] PRIMARY KEY CLUSTERED ([IdStatusChange] ASC),
    CONSTRAINT [FK_StatusBeneficiarySAR_Beneficiary] FOREIGN KEY ([IdBeneficiary]) REFERENCES [dbo].[Beneficiary] ([IdBeneficiary]),
    CONSTRAINT [FK_StatusBeneficiarySAR_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


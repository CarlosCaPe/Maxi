CREATE TABLE [dbo].[TransferOFACInfo] (
    [IdTransferOFACInfo]        INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]                INT            NULL,
    [CustomerName]              NVARCHAR (MAX) NULL,
    [CustomerFirstLastName]     NVARCHAR (MAX) NULL,
    [CustomerSecondLastName]    NVARCHAR (MAX) NULL,
    [CustomerOfacPercent]       FLOAT (53)     NULL,
    [CustomerMatch]             XML            NULL,
    [IsCustomerFullMatch]       BIT            DEFAULT ((0)) NULL,
    [BeneficiaryName]           NVARCHAR (MAX) NULL,
    [BeneficiaryFirstLastName]  NVARCHAR (MAX) NULL,
    [BeneficiarySecondLastName] NVARCHAR (MAX) NULL,
    [BeneficiaryOfacPercent]    FLOAT (53)     NULL,
    [BeneficiaryMatch]          XML            NULL,
    [IsBeneficiaryFullMatch]    BIT            DEFAULT ((0)) NULL,
    [PercentOfacMatchBit]       FLOAT (53)     NULL,
    [MinPercentOfacMatch]       FLOAT (53)     NULL,
    [IsOFACDoubleVerification]  BIT            DEFAULT ((0)) NOT NULL,
    [PercentDoubleVerification] FLOAT (53)     DEFAULT ((0)) NOT NULL,
    [IdUserRelease1]            INT            NULL,
    [UserNoteRelease1]          NVARCHAR (MAX) NULL,
    [DateOfRelease1]            DATETIME       NULL,
    [IdOFACAction1]             INT            NULL,
    [IdUserRelease2]            INT            NULL,
    [UserNoteRelease2]          NVARCHAR (MAX) NULL,
    [DateOfRelease2]            DATETIME       NULL,
    [IdOFACAction2]             INT            NULL,
    [IsCustomerOldProccess]     BIT            DEFAULT ((0)) NOT NULL,
    [IsBeneficiaryOldProccess]  BIT            DEFAULT ((0)) NOT NULL,
    [CanDiscard]                BIT            CONSTRAINT [DF_TransferOFACInfo_CanDiscard] DEFAULT ((0)) NOT NULL,
    [DiscardResolutionMessage]  VARCHAR (1000) NULL,
    CONSTRAINT [PK_TransferOFACInfo] PRIMARY KEY CLUSTERED ([IdTransferOFACInfo] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TransferOFACInfo_Users1] FOREIGN KEY ([IdUserRelease1]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_TransferOFACInfo_Users2] FOREIGN KEY ([IdUserRelease2]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_TransferOFACInfo_IdTransfer]
    ON [dbo].[TransferOFACInfo]([IdTransfer] ASC) WITH (FILLFACTOR = 90);


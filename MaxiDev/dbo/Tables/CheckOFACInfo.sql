CREATE TABLE [dbo].[CheckOFACInfo] (
    [IdCheckOFACInfo]           INT            IDENTITY (1, 1) NOT NULL,
    [IdCheck]                   INT            NULL,
    [CustomerName]              NVARCHAR (MAX) NULL,
    [CustomerFirstLastName]     NVARCHAR (MAX) NULL,
    [CustomerSecondLastName]    NVARCHAR (MAX) NULL,
    [CustomerOfacPercent]       FLOAT (53)     NULL,
    [CustomerMatch]             XML            NULL,
    [IsCustomerFullMatch]       BIT            DEFAULT ((0)) NULL,
    [IssuerName]                NVARCHAR (MAX) NULL,
    [IssuerOfacPercent]         FLOAT (53)     NULL,
    [IssuerMatch]               XML            NULL,
    [IsIssuerFullMatch]         BIT            DEFAULT ((0)) NULL,
    [PercentOfacMatchBit]       FLOAT (53)     NULL,
    [MinPercentOfacMatch]       FLOAT (53)     NULL,
    [IdUserRelease1]            INT            NULL,
    [UserNoteRelease1]          NVARCHAR (MAX) NULL,
    [DateOfRelease1]            DATETIME       NULL,
    [IdOFACAction1]             INT            NULL,
    [IdUserRelease2]            INT            NULL,
    [UserNoteRelease2]          NVARCHAR (MAX) NULL,
    [DateOfRelease2]            DATETIME       NULL,
    [IdOFACAction2]             INT            NULL,
    [IsOFACDoubleVerification]  BIT            DEFAULT ((0)) NOT NULL,
    [PercentDoubleVerification] FLOAT (53)     DEFAULT ((0)) NOT NULL,
    [IsCustomerOldProccess]     BIT            DEFAULT ((0)) NOT NULL,
    [IsIssuerOldProccess]       BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CheckOFACInfo] PRIMARY KEY CLUSTERED ([IdCheckOFACInfo] ASC),
    CONSTRAINT [FK_CheckOFACInfo_Users1] FOREIGN KEY ([IdUserRelease1]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ix_CheckOFACInfo_IdCheck]
    ON [dbo].[CheckOFACInfo]([IdCheck] ASC);


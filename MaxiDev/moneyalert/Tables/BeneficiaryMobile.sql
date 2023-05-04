CREATE TABLE [moneyalert].[BeneficiaryMobile] (
    [IdBeneficiaryMobile] INT            IDENTITY (1, 1) NOT NULL,
    [CountryCode]         VARCHAR (MAX)  NOT NULL,
    [PhoneNumber]         VARCHAR (10)   NOT NULL,
    [Name]                NVARCHAR (MAX) NULL,
    [Token]               NVARCHAR (MAX) NULL,
    [IsOnline]            INT            NOT NULL,
    [EnteredDate]         DATETIME       NOT NULL,
    [DateOfLastChange]    DATETIME       NOT NULL,
    [Photo]               NVARCHAR (MAX) NULL,
    [IdPhoneType]         INT            NULL,
    CONSTRAINT [PK_BeneficiaryMobile] PRIMARY KEY CLUSTERED ([IdBeneficiaryMobile] ASC),
    CONSTRAINT [FK_BeneficiaryMobile_PhoneType] FOREIGN KEY ([IdPhoneType]) REFERENCES [moneyalert].[PhoneType] ([IdPhoneType])
);


CREATE TABLE [dbo].[PhoneValidation] (
    [IdPhoneValidation]        INT          IDENTITY (1, 1) NOT NULL,
    [IdDialingCodePhoneNumber] INT          NOT NULL,
    [IdTelephoneType]          INT          NOT NULL,
    [PhoneNumber]              VARCHAR (20) NOT NULL,
    [CreationDate]             DATETIME     NOT NULL,
    [IsValid]                  BIT          NULL,
    [ValidationDate]           DATETIME     NOT NULL,
    CONSTRAINT [PK_PhoneValidation] PRIMARY KEY CLUSTERED ([IdPhoneValidation] ASC),
    CONSTRAINT [FK_PhoneValidation_DialingCodePhoneNumber] FOREIGN KEY ([IdDialingCodePhoneNumber]) REFERENCES [dbo].[DialingCodePhoneNumber] ([IdDialingCodePhoneNumber]),
    CONSTRAINT [FK_PhoneValidation_TelephoneTypeCatalog] FOREIGN KEY ([IdTelephoneType]) REFERENCES [dbo].[TelephoneTypeCatalog] ([IdTelephoneType]),
    CONSTRAINT [Unique_PhoneNumber] UNIQUE NONCLUSTERED ([PhoneNumber] ASC)
);


CREATE TABLE [dbo].[DialingCodePhoneNumber] (
    [IdDialingCodePhoneNumber] INT           IDENTITY (1, 1) NOT NULL,
    [IdCountry]                INT           NOT NULL,
    [DialingCode]              VARCHAR (25)  NULL,
    [Prefix]                   NVARCHAR (20) NOT NULL,
    [PhoneLength]              INT           NOT NULL,
    [MinPhoneLength]           INT           DEFAULT ((10)) NOT NULL,
    [MaxPhoneLength]           INT           DEFAULT ((10)) NOT NULL,
    CONSTRAINT [PK_DialingCodePhoneNumber] PRIMARY KEY CLUSTERED ([IdDialingCodePhoneNumber] ASC),
    CONSTRAINT [FK_DialingCodePhoneNumber_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry])
);


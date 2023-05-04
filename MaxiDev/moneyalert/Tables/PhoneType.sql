CREATE TABLE [moneyalert].[PhoneType] (
    [IdPhoneType] INT            IDENTITY (1, 1) NOT NULL,
    [Phone]       VARCHAR (MAX)  NOT NULL,
    [AppVersion]  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_PhoneType] PRIMARY KEY CLUSTERED ([IdPhoneType] ASC)
);


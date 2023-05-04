CREATE TABLE [dbo].[CellPhoneVerification] (
    [IdCellPhoneVerification] INT          IDENTITY (1, 1) NOT NULL,
    [PhoneNumber]             VARCHAR (20) NOT NULL,
    [VerificationCode]        VARCHAR (20) NOT NULL,
    [CreationDate]            DATETIME     NOT NULL,
    [ExpirationDate]          DATETIME     NOT NULL,
    [Applied]                 BIT          CONSTRAINT [DF_CellPhoneVerification] DEFAULT ((0)) NOT NULL,
    [EnterByIdUser]           INT          NOT NULL,
    CONSTRAINT [PK_CellPhoneVerification] PRIMARY KEY CLUSTERED ([IdCellPhoneVerification] ASC)
);


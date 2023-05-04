CREATE TABLE [dbo].[Beneficiary] (
    [IdBeneficiary]                   INT            IDENTITY (1, 1) NOT NULL,
    [Name]                            NVARCHAR (MAX) NOT NULL,
    [FirstLastName]                   NVARCHAR (MAX) NOT NULL,
    [SecondLastName]                  NVARCHAR (MAX) NOT NULL,
    [Address]                         NVARCHAR (MAX) NOT NULL,
    [City]                            NVARCHAR (MAX) NOT NULL,
    [State]                           NVARCHAR (MAX) NOT NULL,
    [Country]                         NVARCHAR (MAX) NOT NULL,
    [Zipcode]                         NVARCHAR (MAX) NOT NULL,
    [PhoneNumber]                     NVARCHAR (MAX) NOT NULL,
    [CelullarNumber]                  NVARCHAR (MAX) NOT NULL,
    [SSnumber]                        NVARCHAR (MAX) NOT NULL,
    [BornDate]                        DATETIME       NULL,
    [Occupation]                      NVARCHAR (MAX) NOT NULL,
    [Note]                            NVARCHAR (MAX) NOT NULL,
    [IdGenericStatus]                 INT            NOT NULL,
    [DateOfLastChange]                DATETIME       NOT NULL,
    [EnterByIdUser]                   INT            NOT NULL,
    [IdCustomer]                      INT            NULL,
    [FullName]                        NVARCHAR (120) NULL,
    [IdBeneficiaryIdentificationType] INT            NULL,
    [IdentificationNumber]            NVARCHAR (MAX) NULL,
    [IdCountryOfBirth]                INT            NULL,
    [CreateDate]                      DATETIME       DEFAULT (getdate()) NOT NULL,
    [IdDialingCodePhoneNumber]        INT            NULL,
    CONSTRAINT [PK_Beneficiary] PRIMARY KEY CLUSTERED ([IdBeneficiary] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([IdCountryOfBirth]) REFERENCES [dbo].[CountryBirth] ([IdCountryBirth]),
    CONSTRAINT [FK_Beneficiary_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_Beneficiary_DialingCodePhoneNumber] FOREIGN KEY ([IdDialingCodePhoneNumber]) REFERENCES [dbo].[DialingCodePhoneNumber] ([IdDialingCodePhoneNumber]),
    CONSTRAINT [FK_Beneficiary_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_Beneficiary_IDType] FOREIGN KEY ([IdBeneficiaryIdentificationType]) REFERENCES [dbo].[BeneficiaryIdentificationType] ([IdBeneficiaryIdentificationType]),
    CONSTRAINT [FK_Beneficiary_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ixFullName]
    ON [dbo].[Beneficiary]([FullName] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [Beneficiary_CustomerIncludeBeneficiary]
    ON [dbo].[Beneficiary]([IdCustomer] ASC)
    INCLUDE([IdBeneficiary]) WITH (FILLFACTOR = 90);


GO

Create trigger [dbo].[TR_BeneficiaryFullName]
on [dbo].[Beneficiary] after Insert, Update
as
		
Set nocount on
		Declare @IdBeneficiary int
		Declare @Name nvarchar(40),@FirstLastName nvarchar(40),@SecondLastName nvarchar(40) 
		Select @IdBeneficiary=IdBeneficiary,@Name=Name,@FirstLastName=FirstLastName,@SecondLastName=SecondLastName FROM INSERTED

		Update Beneficiary set FullName=REPLACE ( Substring(@Name,1,40)+Substring(@FirstLastName,1,40)+Substring(@SecondLastName,1,40), ' ','')  where IdBeneficiary=@IdBeneficiary


	IF ((SELECT TRIGGER_NESTLEVEL()) > 0 )
	    RETURN


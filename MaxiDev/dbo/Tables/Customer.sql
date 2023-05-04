CREATE TABLE [dbo].[Customer] (
    [IdCustomer]                   INT             IDENTITY (1, 1) NOT NULL,
    [IdAgentCreatedBy]             INT             NOT NULL,
    [IdCustomerIdentificationType] INT             NULL,
    [IdGenericStatus]              INT             NOT NULL,
    [Name]                         NVARCHAR (MAX)  NOT NULL,
    [FirstLastName]                NVARCHAR (MAX)  NOT NULL,
    [SecondLastName]               NVARCHAR (MAX)  NOT NULL,
    [Address]                      NVARCHAR (MAX)  NOT NULL,
    [City]                         NVARCHAR (MAX)  NOT NULL,
    [State]                        NVARCHAR (MAX)  NOT NULL,
    [Country]                      NVARCHAR (MAX)  NOT NULL,
    [Zipcode]                      NVARCHAR (MAX)  NOT NULL,
    [PhoneNumber]                  NVARCHAR (MAX)  NULL,
    [CelullarNumber]               NVARCHAR (MAX)  NULL,
    [SSNumber]                     NVARCHAR (MAX)  NULL,
    [BornDate]                     DATETIME        NULL,
    [Occupation]                   NVARCHAR (MAX)  NULL,
    [IdentificationNumber]         NVARCHAR (MAX)  NULL,
    [PhysicalIdCopy]               INT             NULL,
    [DateOfLastChange]             DATETIME        NOT NULL,
    [EnterByIdUser]                INT             NOT NULL,
    [ExpirationIdentification]     DATETIME        NULL,
    [IdCarrier]                    INT             NULL,
    [IdentificationIdCountry]      INT             NULL,
    [IdentificationIdState]        INT             NULL,
    [SentAverage]                  DECIMAL (18, 2) CONSTRAINT [SentAverageDefault] DEFAULT ((0)) NOT NULL,
    [FullName]                     NVARCHAR (120)  NULL,
    [IdCountryOfBirth]             INT             NULL,
    [ReceiveSms]                   BIT             DEFAULT ((0)) NOT NULL,
    [CreationDate]                 DATETIME        NULL,
    [OccupationDetail]             NVARCHAR (MAX)  DEFAULT (NULL) NULL,
    [idElasticCustomer]            VARCHAR (MAX)   DEFAULT (NULL) NULL,
    [RequestUpdate]                BIT             DEFAULT ((0)) NOT NULL,
    [UpdateCompleted]              BIT             DEFAULT ((1)) NOT NULL,
    [IdTypeTax]                    INT             NULL,
    [IdTaxDupli]                   INT             NULL,
    [HasAnswerTaxId]               BIT             NULL,
    [IdOccupation]                 INT             NULL,
    [IdSubcategoryOccupation]      INT             NULL,
    [SubcategoryOccupationOther]   VARCHAR (50)    NULL,
    [IdDialingCodePhoneNumber]     INT             NULL,
    CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([IdCustomer] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([IdCountryOfBirth]) REFERENCES [dbo].[CountryBirth] ([IdCountryBirth]),
    FOREIGN KEY ([IdDialingCodePhoneNumber]) REFERENCES [dbo].[DialingCodePhoneNumber] ([IdDialingCodePhoneNumber]),
    CONSTRAINT [FK_Customer_Agent] FOREIGN KEY ([IdAgentCreatedBy]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_Customer_Country] FOREIGN KEY ([IdentificationIdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_Customer_CustomerType] FOREIGN KEY ([IdCustomerIdentificationType]) REFERENCES [dbo].[CustomerIdentificationType] ([IdCustomerIdentificationType]),
    CONSTRAINT [FK_Customer_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_Customer_State] FOREIGN KEY ([IdentificationIdState]) REFERENCES [dbo].[State] ([IdState]),
    CONSTRAINT [FK_Customer_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [ixFullName]
    ON [dbo].[Customer]([FullName] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [nci_CustomerAgent]
    ON [dbo].[Customer]([IdGenericStatus] ASC, [IdAgentCreatedBy] ASC)
    INCLUDE([Name], [FirstLastName], [SecondLastName], [IdCustomer], [CelullarNumber]) WHERE ([IdGenericStatus]=(1));


GO
CREATE NONCLUSTERED INDEX [IX_Customer_IdAgentCreatedBy]
    ON [dbo].[Customer]([IdAgentCreatedBy] ASC, [IdGenericStatus] ASC)
    INCLUDE([IdCustomer]);


GO
CREATE TRIGGER [dbo].[SyncCustomerSearch]
ON [dbo].[Customer]
AFTER INSERT, UPDATE
NOT FOR REPLICATION
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Changes TABLE (IdCustomer INT)

	INSERT INTO @Changes
	SELECT
		i.IdCustomer
	FROM INSERTED i

	DECLARE @CurrentId INT

	WHILE EXISTS(SELECT 1 FROM @Changes)
	BEGIN
		SELECT TOP 1 @CurrentId = c.IdCustomer FROM @Changes c

		EXEC st_UpdateCustomerSearch @CurrentId

		DELETE FROM @Changes WHERE IdCustomer = @CurrentId
	END
END

GO
CREATE TRIGGER [dbo].[DeleteCustomerSearch]
ON [dbo].[Customer]
FOR DELETE
NOT FOR REPLICATION
AS
BEGIN
	SET NOCOUNT ON
	DELETE cs 
	FROM CustomerSearch cs
		JOIN DELETED d ON d.IdCustomer = cs.IdCustomer
END
GO



Create trigger [dbo].[TR_CustomerFullName]
on [dbo].[Customer] after Insert, Update
as
		
Set nocount on
		Declare @IdCustomer int
		Declare @Name nvarchar(40),@FirstLastName nvarchar(40),@SecondLastName nvarchar(40) 
		Select @IdCustomer=IdCustomer,@Name=Name,@FirstLastName=FirstLastName,@SecondLastName=SecondLastName FROM INSERTED

		Update Customer set FullName=REPLACE ( Substring(@Name,1,40)+Substring(@FirstLastName,1,40)+Substring(@SecondLastName,1,40), ' ','')  where IdCustomer=@IdCustomer


	IF ((SELECT TRIGGER_NESTLEVEL()) > 0 )
	    RETURN



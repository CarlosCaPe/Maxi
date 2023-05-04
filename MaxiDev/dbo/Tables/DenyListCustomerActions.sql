CREATE TABLE [dbo].[DenyListCustomerActions] (
    [IdDenyListCustomerAction] INT            IDENTITY (1, 1) NOT NULL,
    [IdDenyListCustomer]       INT            NOT NULL,
    [IdKYCAction]              INT            NOT NULL,
    [MessageInEnglish]         NVARCHAR (MAX) NOT NULL,
    [MessageInSpanish]         NVARCHAR (MAX) NOT NULL,
    [IdTypeRequired]           BIT            DEFAULT ((0)) NOT NULL,
    [IdNumberRequired]         BIT            DEFAULT ((0)) NOT NULL,
    [IdExpirationDateRequired] BIT            DEFAULT ((0)) NOT NULL,
    [IdStateCountryRequired]   BIT            DEFAULT ((0)) NOT NULL,
    [DateOfBirthRequired]      BIT            DEFAULT ((0)) NOT NULL,
    [OccupationRequired]       BIT            DEFAULT ((0)) NOT NULL,
    [SSNRequired]              BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DenyListCustomerActions] PRIMARY KEY CLUSTERED ([IdDenyListCustomerAction] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_DenyListCustomerActions_DenyListCustomer] FOREIGN KEY ([IdDenyListCustomer]) REFERENCES [dbo].[DenyListCustomer] ([IdDenyListCustomer]),
    CONSTRAINT [FK_DenyListCustomerActions_KYCAction] FOREIGN KEY ([IdKYCAction]) REFERENCES [dbo].[KYCAction] ([IdKYCAction])
);


GO
CREATE NONCLUSTERED INDEX [ix_DenyListCustomerActions_IdDenyListCustomer_includes]
    ON [dbo].[DenyListCustomerActions]([IdDenyListCustomer] ASC)
    INCLUDE([IdKYCAction], [MessageInEnglish], [MessageInSpanish]);


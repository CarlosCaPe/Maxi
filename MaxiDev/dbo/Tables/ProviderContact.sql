CREATE TABLE [dbo].[ProviderContact] (
    [IdProviderContact] INT            IDENTITY (1, 1) NOT NULL,
    [IdProvider]        INT            NOT NULL,
    [Name]              NVARCHAR (MAX) NOT NULL,
    [FirstLastName]     NVARCHAR (MAX) NOT NULL,
    [SecondLastName]    NVARCHAR (MAX) NOT NULL,
    [Email]             NVARCHAR (MAX) NOT NULL,
    [PhoneNumber1]      NVARCHAR (MAX) NOT NULL,
    [PhoneNumber2]      NVARCHAR (MAX) NOT NULL,
    [EnterByIdUser]     INT            NOT NULL,
    [DateOfLastChage]   NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_ProviderContact] PRIMARY KEY CLUSTERED ([IdProviderContact] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ProviderContact_Providers] FOREIGN KEY ([IdProvider]) REFERENCES [dbo].[Providers] ([IdProvider]),
    CONSTRAINT [FK_ProviderContact_Users1] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


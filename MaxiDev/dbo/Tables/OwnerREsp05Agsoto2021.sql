CREATE TABLE [dbo].[OwnerREsp05Agsoto2021] (
    [IdOwner]             INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (MAX) NULL,
    [LastName]            NVARCHAR (MAX) NULL,
    [SecondLastName]      NVARCHAR (MAX) NULL,
    [Address]             NVARCHAR (MAX) NULL,
    [City]                NVARCHAR (MAX) NULL,
    [State]               NVARCHAR (MAX) NULL,
    [Zipcode]             NVARCHAR (MAX) NULL,
    [Phone]               NVARCHAR (MAX) NULL,
    [Cel]                 NVARCHAR (MAX) NULL,
    [Email]               NVARCHAR (MAX) NULL,
    [SSN]                 NVARCHAR (MAX) NULL,
    [IdType]              NVARCHAR (MAX) NULL,
    [IdNumber]            NVARCHAR (MAX) NULL,
    [IdExpirationDate]    DATE           NULL,
    [BornDate]            DATE           NULL,
    [BornCountry]         NVARCHAR (MAX) NULL,
    [CreationDate]        DATETIME       NULL,
    [DateofLastChange]    DATETIME       NULL,
    [EnterByIdUser]       INT            NULL,
    [IdStatus]            INT            NULL,
    [CreditScore]         NVARCHAR (MAX) NULL,
    [IdCounty]            INT            NULL,
    [EstadoEmisionID]     INT            NULL,
    [PaisEmisionID]       INT            NULL,
    [FotoNegocioExterior] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_OwnerR] PRIMARY KEY CLUSTERED ([IdOwner] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Owner_GenericStatusR] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_Owner_UsersR] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_Owner_IdStatus]
    ON [dbo].[OwnerREsp05Agsoto2021]([IdStatus] ASC)
    INCLUDE([IdOwner], [Name], [LastName], [SecondLastName], [SSN]);


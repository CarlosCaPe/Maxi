CREATE TABLE [TransFerTo].[Schema] (
    [IdSchema]         INT            IDENTITY (1, 1) NOT NULL,
    [SchemaName]       NVARCHAR (MAX) NOT NULL,
    [IdCountry]        INT            NULL,
    [IdCarrier]        INT            NULL,
    [IdProduct]        INT            NULL,
    [BeginValue]       MONEY          NULL,
    [EndValue]         MONEY          NULL,
    [Commission]       MONEY          NOT NULL,
    [IsDefault]        BIT            NOT NULL,
    [IdGenericStatus]  INT            NOT NULL,
    [DateOfCreation]   DATETIME       NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [IdOtherProduct]   INT            NULL,
    CONSTRAINT [PK_TransferTToSchema] PRIMARY KEY CLUSTERED ([IdSchema] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TToSchema_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_TToSchema_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


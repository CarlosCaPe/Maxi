CREATE TABLE [dbo].[Payer] (
    [IdPayer]          INT            IDENTITY (1, 1) NOT NULL,
    [PayerName]        NVARCHAR (MAX) NOT NULL,
    [PayerCode]        NVARCHAR (MAX) NOT NULL,
    [Folio]            INT            NOT NULL,
    [IdGenericStatus]  INT            NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [PayerLogo]        NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Payer] PRIMARY KEY CLUSTERED ([IdPayer] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Payer_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);


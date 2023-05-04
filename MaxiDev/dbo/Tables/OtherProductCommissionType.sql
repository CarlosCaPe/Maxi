CREATE TABLE [dbo].[OtherProductCommissionType] (
    [IdOtherProductCommissionType] INT            NOT NULL,
    [IdOtherProduct]               INT            NOT NULL,
    [CommissionTypeName]           NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]             DATETIME       NOT NULL,
    [EnterByIdUser]                INT            NOT NULL,
    [IdGenericStatus]              INT            NOT NULL,
    CONSTRAINT [PK_OtherProductCommissionType] PRIMARY KEY CLUSTERED ([IdOtherProductCommissionType] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OtherProductCommissionType_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_OtherProductCommissionType_OtherProduct] FOREIGN KEY ([IdOtherProduct]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts]),
    CONSTRAINT [FK_OtherProductCommissionType_Users1] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


CREATE TABLE [dbo].[CommissionByOtherProducts] (
    [IdCommissionByOtherProducts]  INT            IDENTITY (1, 1) NOT NULL,
    [IdOtherProducts]              INT            NULL,
    [CommissionName]               NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]             DATETIME       NOT NULL,
    [EnterByIdUser]                INT            NOT NULL,
    [IdOtherProductCommissionType] INT            DEFAULT ((0)) NOT NULL,
    [IsEnable]                     BIT            DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_CommissionByProvider] PRIMARY KEY CLUSTERED ([IdCommissionByOtherProducts] ASC) WITH (FILLFACTOR = 90)
);


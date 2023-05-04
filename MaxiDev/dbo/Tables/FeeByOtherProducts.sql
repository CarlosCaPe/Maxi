CREATE TABLE [dbo].[FeeByOtherProducts] (
    [IdFeeByOtherProducts]         INT            IDENTITY (1, 1) NOT NULL,
    [IdOtherProducts]              INT            NULL,
    [FeeName]                      NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]             DATETIME       NOT NULL,
    [EnterByIdUser]                INT            NOT NULL,
    [IdOtherProductCommissionType] INT            DEFAULT ((0)) NOT NULL,
    [IsEnable]                     BIT            DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_FeeByProvider] PRIMARY KEY CLUSTERED ([IdFeeByOtherProducts] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_FeeByProvider_Provider] FOREIGN KEY ([IdOtherProducts]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts])
);


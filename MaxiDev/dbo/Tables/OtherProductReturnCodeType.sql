CREATE TABLE [dbo].[OtherProductReturnCodeType] (
    [IdReturnCodeType] INT            NOT NULL,
    [IdOtherProduct]   INT            NOT NULL,
    [ReturnCodeType]   NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_ReturnCodeTypeTTo] PRIMARY KEY CLUSTERED ([IdReturnCodeType] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OtherProductReturnCodeType_OtherProducts] FOREIGN KEY ([IdOtherProduct]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts])
);


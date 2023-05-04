CREATE TABLE [dbo].[profitHelper] (
    [TypeOfMovement] NVARCHAR (MAX) NOT NULL,
    [AllowCount]     BIT            NULL,
    [idOtherProduct] INT            NULL,
    CONSTRAINT [FK_profitHelper_OtherProducts] FOREIGN KEY ([idOtherProduct]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts])
);


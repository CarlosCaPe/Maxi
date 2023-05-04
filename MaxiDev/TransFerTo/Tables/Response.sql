CREATE TABLE [TransFerTo].[Response] (
    [IdResponse]       INT            IDENTITY (1, 1) NOT NULL,
    [IdOtherProduct]   INT            NOT NULL,
    [IdTransaction]    INT            NOT NULL,
    [IdReturnCodeType] INT            NOT NULL,
    [ReturnCode]       NVARCHAR (MAX) NOT NULL,
    [Message]          NVARCHAR (MAX) NOT NULL,
    [DateOfResponse]   DATETIME       NOT NULL,
    CONSTRAINT [PK_ResponseTTo] PRIMARY KEY CLUSTERED ([IdResponse] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ResponseTTo_OtherProducts] FOREIGN KEY ([IdOtherProduct]) REFERENCES [dbo].[OtherProducts] ([IdOtherProducts]),
    CONSTRAINT [FK_ResponseTTo_ReturnCodeType] FOREIGN KEY ([IdReturnCodeType]) REFERENCES [dbo].[OtherProductReturnCodeType] ([IdReturnCodeType])
);


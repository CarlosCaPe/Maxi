CREATE TABLE [dbo].[Fee] (
    [IdFee]            INT            IDENTITY (1, 1) NOT NULL,
    [FeeName]          NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_Fee] PRIMARY KEY CLUSTERED ([IdFee] ASC) WITH (FILLFACTOR = 90)
);


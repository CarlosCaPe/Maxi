CREATE TABLE [dbo].[PosActionType] (
    [IdPosActionType]  INT            IDENTITY (1, 1) NOT NULL,
    [Code]             NVARCHAR (50)  NOT NULL,
    [PosActionType]    NVARCHAR (100) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_PosActionType] PRIMARY KEY CLUSTERED ([IdPosActionType] ASC) WITH (FILLFACTOR = 90)
);


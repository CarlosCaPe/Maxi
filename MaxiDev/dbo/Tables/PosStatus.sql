CREATE TABLE [dbo].[PosStatus] (
    [IdPosStatus]      SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Code]             NVARCHAR (50)  NOT NULL,
    [PosStatus]        NVARCHAR (100) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_PosStatus] PRIMARY KEY CLUSTERED ([IdPosStatus] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [U_PosStatus_Code] UNIQUE NONCLUSTERED ([Code] ASC)
);


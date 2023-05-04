CREATE TABLE [dbo].[OtherProductStatus] (
    [IdStatus]         INT            NOT NULL,
    [StatusName]       NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_TTStatus] PRIMARY KEY CLUSTERED ([IdStatus] ASC) WITH (FILLFACTOR = 90)
);


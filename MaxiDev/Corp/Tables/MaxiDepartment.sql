CREATE TABLE [Corp].[MaxiDepartment] (
    [IdMaxiDepartment] INT            NOT NULL,
    [MaxiDepartment]   NVARCHAR (150) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_IdMaxiDepartment] PRIMARY KEY CLUSTERED ([IdMaxiDepartment] ASC)
);


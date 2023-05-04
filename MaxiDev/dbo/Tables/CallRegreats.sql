CREATE TABLE [dbo].[CallRegreats] (
    [IdCallRegreats]   INT            IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (100) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_CallRegreats] PRIMARY KEY CLUSTERED ([IdCallRegreats] ASC) WITH (FILLFACTOR = 90)
);


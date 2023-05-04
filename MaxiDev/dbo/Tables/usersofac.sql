CREATE TABLE [dbo].[usersofac] (
    [IdUser]                    INT            IDENTITY (1, 1) NOT NULL,
    [UserName]                  NVARCHAR (MAX) NOT NULL,
    [UserLogin]                 NVARCHAR (MAX) NOT NULL,
    [UserPassword]              NVARCHAR (MAX) NOT NULL,
    [DateOfCreation]            DATETIME       NOT NULL,
    [CreatedByIdUser]           INT            NOT NULL,
    [IdUserType]                INT            NOT NULL,
    [ChangePasswordAtNextLogin] BIT            NOT NULL,
    [AllowToRegisterPc]         BIT            NOT NULL,
    [IdGenericStatus]           INT            NOT NULL,
    [salt]                      NVARCHAR (50)  NOT NULL,
    [DateOfLastChange]          DATETIME       NULL,
    [EnterByIdUser]             INT            NOT NULL
);

